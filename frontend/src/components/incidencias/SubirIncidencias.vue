<template>
  <div class="relative">
    <!-- Botón de subir (fuera del modal) -->
    <div class="flex flex-col items-start z-0">
      <div class="flex flex-row items-center justify-end">
        <label
          class="bg-zinc-50 text-zinc-900 font-medium px-4 py-2 rounded-md cursor-pointer hover:bg-zinc-300 transition duration-300 shadow-md text-nowrap"
        >
          Subir Incidencias
          <input type="file" @change="handleFileChange" accept=".xlsx" class="hidden" />
        </label>
      </div>
    </div>

    <!-- Modal -->
    <div
      role="dialog"
      aria-modal="true"
      v-if="showModal"
      class="fixed inset-0 flex items-center justify-center bg-[#000000dd] z-50 overflow-y-auto"
    >
      <div class="bg-zinc-950 rounded-lg shadow-lg p-6 w-[90%] max-w-2xl max-h-[80vh] overflow-y-auto">
        <h2 class="text-xl font-bold mb-4">Previsualización del archivo</h2>

        <div class="mb-4 p-3 bg-zinc-900 rounded">
          <p class="font-semibold">Resumen:</p>
          <p>{{ parsedExcel.length }} incidencias encontradas</p>
        </div>

        <ul class="list-disc pl-6">
          <li
            v-for="(item, index) in parsedExcel"
            :key="index"
            class="text-sm text-zinc-300"
          >
            {{ item.categoria }} | {{ item.subcategoria }}
          </li>
        </ul>

        <div class="flex justify-end mt-6 gap-2">
          <button
            @click="cancelUpload"
            class="bg-zinc-900 text-zinc-50 px-4 py-2 rounded cursor-pointer hover:bg-zinc-800"
          >
            Cancelar
          </button>
          <button
            @click="confirmUpload"
            class="bg-zinc-50 text-zinc-950 px-4 py-2 rounded cursor-pointer hover:bg-zinc-200"
          >
            Aceptar
          </button>
        </div>

        <!-- Aquí: mensaje de estado de la subida -->
        <p v-if="uploadStatus" class="mt-4 text-sm text-green-400">
          {{ uploadStatus }}
        </p>
      </div>
    </div>
  </div>
</template>


<script>
import ExcelJS from 'exceljs';
const API_URL = import.meta.env.PUBLIC_API_URL;

export default{
  data(){
    return{
      selectedFile: null,
      parsedExcel: [],
      showModal: false,
      uploadStatus: '',
    };
  },
  mounted() {
  window.addEventListener('abrir-modal', () => {
    this.showModal = true;
  });
},
  methods:{
    async handleFileChange(event){
      const file = event.target.files[0];
      if(!file || !file.name.endsWith('.xlsx')){
        alert('Por favor, sube un archivo .xlsx válido.');
        return;
      }
      try{
        const data = await this.parseExcel(file);
        this.parsedExcel = data;
        console.log(this.parsedExcel);
        this.showModal = true;
      }catch (error){
        alert(`Error al procesar el archivo: ${error.message}`);
        console.error(error);
      }
    },

    async parseExcel(file){
      const workbook = new ExcelJS.Workbook();
      const buffer = await file.arrayBuffer();
      await workbook.xlsx.load(buffer);

      // LA CONST WORKSHEET, BUSCA LA HOJA DE CALCULO CON EL NOMBRE 'incidencias'
      // EN ESTE CASO, SE ASUME QUE EL ARCHIVO DEBE TENER UNA HOJA CON ESE NOMBRE
      // SI NO EXISTIERA, ENTONCES DEBERÍA LEER EL WORKSHEET 0 (PRIMERA HOJA)
      let worksheet = workbook.getWorksheet('incidencias');
      if (!worksheet) {
        worksheet = workbook.worksheets[0];
      }
      const headerRow = worksheet.getRow(1);
      const headers = headerRow.values.slice(1);

      const expectedHeaders = ['categoria', 'subcategoria'];
      if(JSON.stringify(headers) !== JSON.stringify(expectedHeaders)){
        throw new Error(`El archivo debe contener las columnas exactas: ${expectedHeaders.join(', ')}`);
      }

      const rows = [];
      worksheet.eachRow((row, rowIndex) =>{
        if(rowIndex === 1) return;
        const [, categoria, subcategoria] = row.values;
        if (!categoria || !subcategoria) return;
        rows.push({ categoria, subcategoria });
      });

      return rows;
    },

    async confirmUpload(){
      this.showModal = false;
      this.uploadStatus = 'Subiendo datos...';
      try{
        await this.sendDataToBackend(this.parsedExcel);
        this.uploadStatus = 'Archivo subido y procesado correctamente';
        this.parsedExcel = [];
        this.selectedFile = null;
        setTimeout(() => {
          window.location.reload();
        }, 1000);
      }catch (error){
        this.uploadStatus = 'Error al subir los datos.';
        console.error(error);
      }
    },

    cancelUpload(){
      this.selectedFile = null;
      this.parsedExcel = [];
      this.showModal = false;
      this.uploadStatus = '';
    },

    async sendDataToBackend(parsedData){
      //console.log("ID de la instancia:", this.id);
      const deleted = await this.deleteInicendiasDataToBackend();
      if(!deleted){
        console.error("No se pudo eliminar incidencias antes de subir nuevas.");
        return;
      }
      else{
        for(const item of parsedData){
          //console.log("Categoría:", item.categoria);
          //console.log("Categoría:", item.subcategoria);
          try{
            const response = await fetch(`${API_URL}/api/incidencias`,{
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({
                categoria: item.categoria,
                subcategoria: item.subcategoria
              })
            });
          }catch(error){
            console.error("Error de red:", error);
          }
        }
      }
    }, 
    async deleteInicendiasDataToBackend(){
      try{
        const response = await fetch(`${API_URL}/api/incidencias`,{
            method: 'DELETE',
            headers: { 'Content-Type': 'application/json' },
          });
        if(!response.ok){
          throw new Error(`Error al eliminar incidencias: ${response.statusText}`);
        }
        console.log('Incidencias eliminadas correctamente');
        return true;
      }catch(error){
        console.error("Error de red:", error);
        return false;
      }
    }
  }
};
</script>
