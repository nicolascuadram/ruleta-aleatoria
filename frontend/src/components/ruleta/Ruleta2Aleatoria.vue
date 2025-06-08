<template>
  <div class="stage notstarted">
    <div class="wheel-system">
      <div class="row console">
        <div class="console-outer">
          <div id="col1" class="col third wheel">
            <div class="wheel-container">
              <ul id="ring1" class="ring">
                <li v-for="(item, index) in item"
                    :key="'ring1-' + index"
                    :data-content="item"
                    class="item">
                  <div class="item-content"> 
                    <span>{{ item }}</span>
                  </div>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div class="button-area">
      <button id="play" class="trigger">Girar ruleta</button>
    </div>
    <div class="results">
      <div id="textcontent">Esperando</div>
    </div>
  </div>
</template>

<script>
import { gsap } from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
gsap.registerPlugin(ScrollTrigger);

const API_URL = import.meta.env.PUBLIC_API_URL;

export default{
  props:{
    id: {
      type: String,
      required: true
    }
  },
  data(){
    return{
      seed: Date.now(),
      item: [], // Lo que se muestra actualmente en la ruleta
      item2: {}, // Subcategorías por categoría
      incidencias: [],
      categoriaSeleccionada: null,
      turno: 1 // 1: categorías, 2: subcategorías, 3: categorías, etc.
    };
  },
  mounted(){
    this.getIncidencias();
    document.querySelector('button.trigger').addEventListener('click', this.spinWheels);
  },
  methods:{
    async getIncidencias(){
      try{
        const response = await fetch(`${API_URL}/api/incidencias/${this.id}`);
        if(!response.ok) throw new Error(`Error del servidor: ${response.statusText}`);

        const data = await response.json();
        this.incidencias = data;

        // Agrupar categorías únicas
        const categorias = [...new Set(data.map(i => i.categoria))];
        this.item2 = {};

        categorias.forEach(categoria =>{
          this.item2[categoria] = [
            ...new Set(data.filter(i => i.categoria === categoria).map(i => i.subcategoria))
          ];
        });

        this.item = categorias; // Primer giro es de categorías

        this.$nextTick(this.setupRing);
      } catch (err) {
        console.error("Error fetching incidencias:", err);
      }
    },

    xorshift(){
      let x = this.seed >>> 0;
      x ^= x << 13;
      x ^= x >> 17;
      x ^= x << 5;
      this.seed = x >>> 0;
      return this.seed;
    },

    setupRing(){
      const anglePerItem = 360 / this.item.length;
      gsap.set(".ring", { rotationX: 0 });

      gsap.utils.toArray(".item").forEach((el, i) => {
        gsap.set(el, {
          rotateX: i * -anglePerItem,
          transformOrigin: "50% 50% -200px",
          z: 200,
        });
      });
    },

    spinWheels(){
      const isTurnoCategoria = this.turno % 2 === 1;

      if(isTurnoCategoria){
        this.item = Object.keys(this.item2);
      }else{
        if(!this.categoriaSeleccionada || !this.item2[this.categoriaSeleccionada]){
          alert("No hay subcategorías para la categoría seleccionada.");
          return;
        }
        this.item = this.item2[this.categoriaSeleccionada];
      }

      if(this.item.length === 0){
        alert("No hay datos para mostrar.");
        return;
      }

      this.$nextTick(() => {
        this.setupRing();
        this.startSpin(this.item.length);
      });
    },

    startSpin(itemCount){
      const anglePerItem = 360 / itemCount;
      const fullRotations = (this.xorshift() % 10) + 1;
      const targetIndex = Math.floor(this.xorshift() % itemCount);
      const targetAngle = fullRotations * 360 + targetIndex * anglePerItem;

      document.querySelector('.stage').classList.remove('notstarted');
      document.querySelectorAll('.ring .item').forEach(item => item.classList.remove('active'));
      document.getElementById('textcontent').innerHTML = `<p>Girando...</p>`;

      gsap.to('#ring1', {
        rotationX: targetAngle,
        duration: 6 + fullRotations * 0.3,
        ease: 'power2.inOut',
        onComplete: this.finishScroll
      });
    },

    finishScroll(){
      const ring = document.querySelector('#ring1');
      const items = ring.querySelectorAll('.item');
      const itemCount = items.length;
      const anglePerItem = 360 / itemCount;

      let rotation = (gsap.getProperty(ring, "rotationX") % 360 + 360) % 360;
      const visualOffset = anglePerItem / 2;
      const normalizedAngle = (rotation + visualOffset) % 360;
      const winningIndex = Math.floor(normalizedAngle / anglePerItem) % itemCount;
      const winningItem = items[winningIndex];

      if (!winningItem) return;

      const resultado = winningItem.dataset.content;
      document.getElementById('textcontent').innerHTML = `<p>Resultado: ${resultado}</p>`;

      // Guardar categoría para subcategoría futura
      if (this.turno % 2 === 1) {
        this.categoriaSeleccionada = resultado;
      }

      // Guardar en backend
      fetch('http://localhost:3000/api/ruleta', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ resultado })
      }).catch(err => {
        console.error('Error guardando resultado:', err);
      });

      items.forEach(item => item.classList.remove('active'));
      winningItem.classList.add('active');

      gsap.to(winningItem, {
        scale: 1.1,
        duration: 0.5,
        yoyo: true,
        repeat: 1
      });

      this.turno++;
    }
  }
};
</script>


<style scoped>
.wheel-system {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 100%;
  height: 100%;
}
.stage {
  width: 100%;
  display: flex;
  flex-direction: column;
  height: 100%;
  position: relative;
  justify-content: center;
}

.button-area {  
  padding: 1% 0;
  text-align: center;
  margin: auto;
  display: flex;
  flex-direction: column;
  justify-content: center;
}
.results{
  display: none;
}

button {
  text-align: center;
  display: inline-block;
  border-radius: 5px;
  font-size: 1.5em;
  padding: 10px 27px;
  background: transparent;
  border: 2px solid white;
  color: white;
  transition: all 0.2s ease;
}

button:hover {
  background: white;
  color: #16a085;
  border-color: #16a085;
}

.item, .console-outer {
  width: 100%;
  height: 100%;
  transform-style: preserve-3d;
  user-select: none;
}

.ring {
  width: 300px;
  height: 300px;
  position: relative;
  transform-style: preserve-3d;
  list-style: none;
  padding: 0;
  margin: 0;
  background: transparent;
  border: none;
  box-shadow: none;
  pointer-events: none; /* Opcional: permite clicks en los items */
}

/* Asegúrate que los items sean visibles */
.item {
  pointer-events: auto; /* Permite interactuar con los items */
  /* Resto de tus estilos para items... */
}

.item {
  position: absolute;
  width: 100%;
  height: 100%;
  transform-style: preserve-3d;
  backface-visibility: hidden;
}

.item-content {
  position: absolute;
  width: 100%;
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
  background: white;
  border: 1px solid #ccc;
  transform: translateZ(150px); /* ¡Clave para posición 3D! */
}

.row.console {
  flex: 1 1 auto;
  display: flex;
  height: 100%;
  flex-direction: column;
  justify-content: center;
  margin-top: 5%;
  width: 100%;
}

.console-outer {
  max-height: 460px;
  min-height: 130px;
  flex: 1 1 auto;
  box-shadow: 0 5px 20px 0px #07352b80;
  display: flex;
  flex-direction: row;
  max-width: 465px;
  margin: auto;
  margin-bottom: 20px;
  gap: 2px;
  border: 15px solid black;
  border-left: none;
  border-right: none;
  border-radius: 15px;
}

.col.wheel {
  background: black;
  padding: 0;
  max-height: 100%;
  min-height: 100%;
  height: 100%;
  overflow: hidden;
  margin: auto;
  flex: 0 0 100%;
  max-width: 100%;
  position: relative;
}

.wheel-container {
  perspective: 2000px;
  width: 300px;
  height: 300px;
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);
  position: relative;
  transform-style: preserve-3d; 
}


ul {
  list-style: none;
  padding: 0;
}

.item span {
  font-size: 1.5em;
  font-weight: bold;
  color: #333;
  text-align: center;
  width: 100%;
}

.item.active {
  opacity: 1;
  box-shadow: 0 0 10px gold;
  background: #fffacd;
}

.stage.notstarted .active {
  box-shadow: none;
}
</style>