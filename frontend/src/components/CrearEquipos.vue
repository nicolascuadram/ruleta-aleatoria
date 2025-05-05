<template>
  <div class="relative">
    <div class="flex flex-col items-center w-full p-4 border-t border-zinc-700 z-0">
      <div class="flex flex-row items-center justify-center space-x-4">
        <div  v-if="!hasGroups">
          <h1>Subir equipos:</h1>
        </div>
        <div v-else>
          <!-- OJO COMO MANEJAMOS LO DE EDITAR -->
          <h1>Agregar mas equipos:</h1>
        </div>
        <label class="bg-white text-black border border-gray-300 px-4 py-2 rounded cursor-pointer hover:bg-gray-100">
          Subir archivo CSV
          <input type="file" @change="handleFileChange" accept=".csv" class="hidden" />
        </label>
      </div>
    <div class="mt-4 text-sm text-gray-300 text-center min-h-[1.25rem]">
      <p>{{ uploadStatus }}</p>
    </div>
  </div>
  <!--Modal-->
  <div v-if="showModal" class="fixed inset-0 bg-opacity-30 backdrop-blur-sm flex items-center justify-center z-50 overflow-y: auto;">
  <div class="bg-white text-black rounded-lg shadow-lg p-6 w-[90%] max-w-2xl max-h-[80vh] overflow-y-auto">
    <h2 class="text-xl font-bold mb-4">Previsualización del archivo</h2>
    <div class="mb-4 p-3 bg-blue-50 rounded">
      <p class="font-semibold">Resumen:</p>
      <p>{{ Object.keys(groupedPreview).length }} grupos distintos</p>
      <p>{{ parsedCSV.length }} alumnos </p>
    </div>
    <div v-for="(alumnos, grupo) in groupedPreview" :key="grupo" class="mb-4">
      <h3 class="text-lg font-semibold">Grupo: {{ grupo }}</h3>
      <p class="text-sm text-gray-600">{{ alumnos.length }} alumnos</p>
      <ul class="list-disc pl-6">
        <li v-for="(nombre, index) in alumnos" :key="index">{{ nombre }}</li>
      </ul>
    </div>
    
    <div class="flex justify-end mt-6">
      <button @click="confirmUpload" class="bg-green-600 text-white px-4 py-2 mr-2 rounded">Aceptar</button>
      <button @click="cancelUpload" class="bg-red-600 text-white px-4 py-2 rounded">Cancelar</button>
    </div>
  </div>
</div>
</div>
</template>


<script>
import Papa from "papaparse";

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
      parsedCSV: [],
      showModal: false,
      groupsAndStudents: [],
      groupedPreview: {},
    };
  },
  methods:{
    async fetchGruposPorInstancia(){
      try{
        const response = await fetch(API_URL + `/api/instancias/${this.id}`);
        if(!response.ok) throw new Error('Failed to fetch instance');

        const data = await response.json();
        //console.log("Datos recibidos:", data); // Para ver el contenido de la respuesta

        if(Array.isArray(data)&&data.length > 0){ // Verifica si es un array y tiene elementos
          this.hasGroups = true;
        }else{
          this.hasGroups = false;
        }
      }catch (error){
        //console.error('Error fetching instance:', error);
        this.hasGroups = false;
      }
    },

    parseCSV(file){
      return new Promise((resolve, reject)=>{
        if(!file){
          reject(new Error("No se seleccionó ningún archivo."));
          return;
        }
        // Validar extensión del archivo
        if (!file.name.toLowerCase().endsWith('.csv')) {
          reject(new Error("El archivo debe tener extensión .csv"));
          return;
        }
        Papa.parse(file,{
          header: true,
          skipEmptyLines: true,
          delimitersToGuess: [',', ';', '\t', '|'],
          encoding: 'UTF-8',
          complete: (result)=>{
            if(!result.data || result.data.length === 0){
              reject(new Error("El archivo está vacío o no contiene datos válidos."));
              return;
            }
            if(result.errors && result.errors.length > 0){
              const errorMessages = result.errors.map(err => 
                `Línea ${err.row || 'desconocida'}: ${err.message}`
              ).join('\n');
              reject(new Error(`Errores encontrados:\n${errorMessages}`));
              return;
            }
            // Validar estructura del CSV
            const isValid = this.validateCSVStructure(result.data);
            if (!isValid.valid) {
              reject(new Error(isValid.message));
              return;
            }
            // Validar contenido de los datos
            const contentValidation = this.validateCSVContent(result.data);
            if (!contentValidation.valid) {
              reject(new Error(contentValidation.message));
              return;
            }
            resolve(result.data);
          },
          error: (err) => {
            reject(new Error(`Error al analizar el archivo CSV: ${err.message}`));
          }
        });
      });
    },

    // Validar que el CSV tenga las columnas correctas
    validateCSVStructure(data){
      if(data.length === 0){
        return { valid: false, message: "El archivo no contiene datos." };
      }
      const firstRow = data[0];
      if(!('grupo' in firstRow)||!('nombre' in firstRow)){
        return{ 
          valid: false, 
          message: "El archivo CSV debe contener las columnas 'grupo' y 'nombre'." 
        };
      }
      return{ valid: true };
    },
  
    // Validar el contenido de los datos
    validateCSVContent(data){
      const errors = [];
      data.forEach((row, index) =>{
        const lineNumber = index + 2;
        if(!row.grupo || row.grupo.trim() === ''){
          errors.push(`Línea ${lineNumber}: El campo 'grupo' no puede estar vacío.`);
        }
        if (!row.nombre || row.nombre.trim() === ''){
          errors.push(`Línea ${lineNumber}: El campo 'nombre' no puede estar vacío.`);
        }
        /*
        // Validar longitud máxima si es necesario
        if(row.grupo && row.grupo.length > 50){
          errors.push(`Línea ${lineNumber}: El nombre del grupo no puede exceder 50 caracteres.`);
        }
        if(row.nombre && row.nombre.length > 100){
          errors.push(`Línea ${lineNumber}: El nombre del alumno no puede exceder 100 caracteres.`);
        }
        */
      });
      if(errors.length > 0){
        return { 
          valid: false, 
          message: `Errores encontrados:\n${errors.join('\n')}` 
        };
      }
    return { valid: true };
    },

    //Función para seleccionar archivo
    async handleFileChange(event){
      this.selectedFile = event.target.files[0];
      this.uploadStatus = '';
      if(!this.selectedFile){
        this.uploadStatus = 'No se seleccionó ningún archivo.';
        return;
      }

      try{
        const parsed = await this.parseCSV(this.selectedFile);
        this.parsedCSV = parsed;
        this.groupedPreview = this.groupByGroup(parsed);
        this.showModal = true;
      }catch (err){
        console.error('Error al procesar CSV:', err);
        let errorMessage = 'Error al procesar el archivo CSV.';
        if(err.message.includes('delimiting character')){
          errorMessage = 'El archivo CSV no está bien formateado. Asegúrese que usa comas (,) como separadores.';
        }else if(err.message.includes('extensión')){
          errorMessage = 'El archivo debe ser un CSV válido con extensión .csv';
        }else{
          errorMessage = err.message;
        }
        this.uploadStatus = errorMessage;
        event.target.value = ''; 
      }
    },
    
    //Función para mostrar grupos y estudiantes
    organizeGroupsAndStudents(parsedData){
      const groups = {};
      for(const item of parsedData){
        if(!groups[item.grupo]){
          groups[item.grupo] = [];
        }
        groups[item.grupo].push(item.nombre);
      }
      this.groupsAndStudents = Object.keys(groups).map(groupName =>({
        nombre: groupName,
        alumnos: groups[groupName],
      }));
    },


    groupByGroup(data){
      const grouped = {};
      for(const item of data){
        if(!grouped[item.grupo]){
          grouped[item.grupo] = [];
        }
        grouped[item.grupo].push(item.nombre);
      }
      return grouped;
    },

    //Confirmar carga
    async confirmUpload(){
      this.showModal = false;
      this.uploadStatus = 'Subiendo datos...';

      try{
        await this.sendDataToBackend(this.parsedCSV);
        this.organizeGroupsAndStudents(this.parsedCSV);
        this.uploadStatus = 'Archivo subido y procesado correctamente';
        this.parsedCSV = [];
        this.selectedFile = null;
        setTimeout(() => {
          window.location.reload();
        }, 1000);
      }catch (error){
        this.uploadStatus = 'Error al subir los datos.';
        console.error(error);
      }
    },

    // Cancelar la carga
    cancelUpload(){
      this.selectedFile = null;
      this.parsedCSV = [];
      this.showModal = false;
      this.uploadStatus = '';
    },

    async sendDataToBackend(parsedData){
      const gruposCreados = {};

      for(const item of parsedData){
        let grupoId;

        if(!gruposCreados[item.grupo]){
          const groupData ={
            ref_instancia: this.id,
            nombre: item.grupo,
          };
          const nuevoGrupo = await this.createGroup(groupData);
          grupoId = nuevoGrupo.id;
          gruposCreados[item.grupo] = grupoId;
        } else {
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
      const response = await fetch('http://localhost:3000/api/grupos',{
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(groupData),
      });
      return await response.json();
    },

    async createAlumno(alumnoData) {
      const response = await fetch('http://localhost:3000/api/alumnos',{
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(alumnoData),
      });
      return await response.json();
    },

    async fetchData() {
      // Llamar a la función asíncrona dentro de un método separado
      await this.fetchGruposPorInstancia();
      console.log(this.hasGroups);
    },
  },
  mounted() {
    // Llamar al método fetchData desde mounted()
    this.fetchData();
  },
};
</script>


