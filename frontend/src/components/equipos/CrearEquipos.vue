<template>
  <div class="relative">
    <div class="flex flex-col items-start z-0">
      <div class="flex flex-row items-center justify-end">
        <!-- <div  v-if="!hasGroups">
          <h1>Subir equipos:</h1>
        </div>
        <div v-else> -->
        <!-- OJO COMO MANEJAMOS LO DE EDITAR -->
        <!-- <h1 class="text-nowrap">Agregar mas equipos:</h1>
        </div> -->
        <label
          class="bg-zinc-50 text-zinc-900 font-medium px-4 py-2 rounded-md cursor-pointer hover:bg-zinc-300 transition duration-300 shadow-md text-nowrap">
          Subir Equipos
          <input type="file" @change="handleFileChange" accept=".xlsx" class="hidden" />
        </label>
      </div>
      <!-- <div class="mt-4 text-sm text-gray-300 text-center min-h-[1.25rem]">
        <p>{{ uploadStatus }}</p>
      </div> -->
    </div>
    <!--Modal-->
    <div role="dialog" aria-modal="true" v-if="showModal" class="fixed inset-0 flex items-center justify-center bg-[#000000dd] z-50 overflow-y-auto">
      <div class="bg-zinc-950 rounded-lg shadow-lg p-6 w-[90%] max-w-2xl max-h-[80vh] overflow-y-auto">
        <h2 class="text-xl font-bold mb-4">Previsualización del archivo</h2>
        <div class="mb-4 p-3 bg-zinc-900 rounded">
          <p class="font-semibold">Resumen:</p>
          <p>{{ Object.keys(groupedPreview).length }} grupos distintos</p>
          <p>{{ parsedExcel.length }} alumnos </p>  
        </div>
        <div v-for="(grupoData, grupoNombre) in groupedPreview" :key="grupoNombre">
          <h3 class="text-lg font-semibold">Grupo: {{ grupoNombre }}</h3>
          <ul class="list-disc pl-6">
            <!-- Proyecto 1 -->
            <p class="text-sm font-semibold">
              Proyecto 1:  {{ grupoData.proyecto1 }} 
            </p>
            <p class="text-sm font-semibold">
              Proyecto 2: {{ grupoData.proyecto2 }} 
            </p>
            <!--Integrantes-->
            <ul>
              <li
                v-for="(alumno, index) in grupoData.alumnos"
                :key="index"
              >
                <p class="text-sm text-zinc-600"> -{{ alumno }}</p>
              </li>
            </ul>
          </ul>
        </div>
        <div class="flex justify-end mt-6 gap-2">
          <button @click="cancelUpload" class="bg-zinc-900 text-zinc-50 px-4 py-2 rounded cursor-pointer hover:bg-zinc-800">Cancelar</button>
          <button @click="confirmUpload" class="bg-zinc-50 text-zinc-950 px-4 py-2 rounded cursor-pointer hover:bg-zinc-200">Aceptar</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import ExcelJS from 'exceljs';

const API_URL = import.meta.env.PUBLIC_API_URL;

export default{
  props:{
    id:{
      type: String,
      required: true
    }
  },
  data(){
    return {
      hasGroups: false,
      selectedFile: null,
      uploadStatus: '',
      parsedExcel: [],
      showModal: false,
      groupedPreview: {},
    };
  },
  methods:{
    async fetchGruposPorInstancia(){
      try{
        const response = await fetch(`${API_URL}/api/instancias/${this.id}`);
        if(!response.ok) throw new Error('Failed to fetch instance');
        const data = await response.json();
        this.hasGroups = Array.isArray(data) && data.length > 0;
      }catch(error){
        this.hasGroups = false;
      }
    },

    async handleFileChange(event){
      const file = event.target.files[0];
      if(!file || !file.name.endsWith('.xlsx')){
        alert('Por favor, sube un archivo .xlsx válido.');
        return;
      }
      try{
        const data = await this.parseExcel(file);
        //console.log("data");
        //console.log(data);
        this.parsedExcel = this.flattenRows(data);
        //console.log("parsed");
        //console.log(this.parsedExcel);
        this.groupedPreview = this.createGroupedPreview(data);
        //console.log("previews");
        //console.log(this.groupedPreview);
        this.showModal = true;
      } catch (error) {
        alert(`Error al procesar el archivo: ${error.message}`);
        console.error(error);
      }
    },

    async parseExcel(file){
      const workbook = new ExcelJS.Workbook();
      const buffer = await file.arrayBuffer();
      await workbook.xlsx.load(buffer);

      const worksheet = workbook.worksheets[0];
      const headerRow = worksheet.getRow(1);
      const headers = headerRow.values.slice(1);

      const expectedHeaders =['Grupo', 'Proyecto1', 'Proyecto2', 'NumIntegrantes', 'Integrante1', 'Integrante2', 'Integrante3', 'Integrante4', 'Integrante5', 'Integrante6'];
      if(JSON.stringify(headers) !== JSON.stringify(expectedHeaders)){
        throw new Error(`El archivo debe contener las columnas exactas: ${expectedHeaders.join(', ')}`);
      }
      const rows = [];
      worksheet.eachRow((row, rowIndex) =>{
        if (rowIndex === 1) return; // Saltar cabecera
        const[, grupo, proyecto1, proyecto2, numIntegrantes, i1, i2, i3, i4, i5, i6] = row.values;
        const integrantes = [i1, i2, i3, i4, i5, i6].filter(i => typeof i === 'string' && i.trim() !== '');
        if (!grupo || !numIntegrantes) return;
        rows.push({
          grupo,
          proyecto1,
          proyecto2,
          integrantes
        });
      });

      return rows;
    },

    flattenRows(data){
      // Transforma cada grupo con múltiples integrantes a múltiples objetos individuales
      const flat = [];
      for (const item of data){
        item.integrantes.forEach(nombre =>{
          flat.push({
            grupo: item.grupo,
            proyecto1: item.proyecto1,
            proyecto2: item.proyecto2,
            nombre
          });
        });
      }
      return flat;
    },

    createGroupedPreview(data){
      const grouped = {};
      for (const item of data){
        grouped[item.grupo] ={
          grupo: item.grupo,
          proyecto1: item.proyecto1,
          proyecto2: item.proyecto2,
          alumnos: item.integrantes
        };
      }
      return grouped;
    },

    async confirmUpload(){
      this.showModal = false;
      this.uploadStatus = 'Subiendo datos...';
      try {
        await this.sendDataToBackend(this.parsedExcel);
        this.uploadStatus = 'Archivo subido y procesado correctamente';
        this.parsedExcel = [];
        this.selectedFile = null;
        setTimeout(() => {
          window.location.reload();
        }, 1000);
      } catch (error){
        this.uploadStatus = 'Error al subir los datos.';
        console.error(error);
      }
    },

    cancelUpload(){
      this.selectedFile = null;
      this.parsedExcel = [];
      this.groupedPreview = {};
      this.showModal = false;
      this.uploadStatus = '';
    },

    async sendDataToBackend(parsedData){
      const gruposCreados = {};

      for(const item of parsedData){
        let grupoId;

        if(!gruposCreados[item.grupo]){
          const groupData = {
            ref_instancia: this.id,
            nombre: `Grupo ${item.grupo}`,
            proyecto1: item.proyecto1,
            proyecto2: item.proyecto2,
          };
          const nuevoGrupo = await this.createGroup(groupData);
          grupoId = nuevoGrupo.id;
          gruposCreados[item.grupo] = grupoId;
        }else{
          grupoId = gruposCreados[item.grupo];
        }

        const alumnoData ={
          ref_grupo: grupoId,
          nombre: item.nombre,
        };
        await this.createAlumno(alumnoData);
      }
    },

    async createGroup(groupData){
      const response = await fetch(`${API_URL}/api/grupos`,{
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(groupData),
      });
      return await response.json();
    },

    async createAlumno(alumnoData){
      const response = await fetch(`${API_URL}/api/alumnos`,{
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(alumnoData),
      });
      return await response.json();
    },

    async fetchData(){
      await this.fetchGruposPorInstancia();
    },
  },

  mounted() {
    this.fetchData();
  },
};
</script>
