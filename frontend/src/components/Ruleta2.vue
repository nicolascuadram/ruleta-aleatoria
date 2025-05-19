<template> 
    <div class="stage notstarted">
      <div class="row console">
        <div class="console-outer">
          <div id="col1" class="col third wheel">
            <div class="container">
              <ul id="ring1" class="ring">
                <li v-for="(item, index) in items" 
                :key="'ring1-'+index" 
                :data-content="item" 
                class="item">
                  <span>{{ item }}</span>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    <div class="button-area"><button id="play" class="trigger">Girar ruleta</button></div>
        <div class="results">
            <div id="textcontent">Esperando</div>
        </div>
    </div>
</template>

<script>
import { gsap } from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

export default {
  data() {
    return {
      items: ['Organizacional','Operativo','Tecnológico','Proyecto','Personal','Organizacional','Operativo','Tecnológico','Proyecto','Personal','Organizacional','Operativo','Tecnológico','Proyecto','Personal']
    }
  },
  mounted() {
    this.initGame();
  },
  methods: {
    initGame() {
      const itemCount = this.items.length;
      const anglePerItem = 360 / itemCount;

      // Solo configurar, no animar
      gsap.set(".ring", { rotationX: -90 });
      gsap.set(".item", {
        rotateX: (i) => (i * -anglePerItem),
        transformOrigin: "50% 50% -220px",
        z: 220,
      });

      // Registrar el botón
      document.querySelector('button.trigger').addEventListener('click', this.spinWheels);
      document.querySelectorAll('button.hold').forEach(btn => {
        btn.addEventListener('click', this.toggleHold);
      });
    },
    finishScroll() {
      const ring = document.querySelector('#ring1');
      const items = ring.querySelectorAll('.item');

      let winningItem = null;
      let maxArea = 0;

      items.forEach(item => {
        const rect = item.getBoundingClientRect();

        // Filtrar ítems completamente fuera de pantalla (o invisibles)
        if (rect.width === 0 || rect.height === 0) return;
        if (rect.bottom < 0 || rect.top > window.innerHeight) return;

        // Calcular el área visible como aproximación de "visibilidad frontal"
        const area = rect.width * rect.height;

        if (area > maxArea) {
          maxArea = area;
          winningItem = item;
        }
      });

      // Mostrar resultado
      const textcontent = document.getElementById('textcontent');
      if (winningItem) {
        textcontent.innerHTML = `<p>Resultado: ${winningItem.dataset.content}</p>`;
        items.forEach(item => item.classList.remove('active'));
        winningItem.classList.add('active');
      } else {
        textcontent.innerHTML = `<p>No se pudo determinar el resultado</p>`;
      }
    },  
    spinWheels() {
      const itemCount = this.items.length;
      const anglePerItem = 360 / itemCount;

      const textcontent = document.getElementById('textcontent');
      textcontent.innerHTML = '<p>Cargando...</p>';

      document.querySelector('.stage').classList.remove('notstarted');
      document.querySelectorAll('.ring:not(.held) .item').forEach(item => {
        item.classList.remove('active');
      });

      // Gira de forma aleatoria pero en múltiplos del ángulo por ítem
      const fullRotations = 5;
      const targetIndex = Math.floor(Math.random() * itemCount);
      const targetAngle = fullRotations * 360 + targetIndex * anglePerItem;

      const scrollcells = gsap.timeline({ paused: true, onComplete: this.finishScroll })
        .to('#ring1:not(.held)', {
          rotationX: `+=${targetAngle}`,
          duration: 2,
          ease: 'power3',
        }, "<");

      scrollcells.play();
    },
  }
}
</script>

<style scoped>
svg, ul, li, .container {
  position: absolute;
}
.stage {
  width: 100%;
  display: flex;
  flex-direction: column;
  height: 100%;
  position: relative;
  justify-content: center;
}
.results, .button-area {  
  padding: 1% 0;
  text-align: center;
  margin: auto;
  display: flex;
  flex-direction: column;
  justify-content: center;
}
.results {
  margin-top: 0;
}
.button-area {
  margin-bottom: 0;
  margin-top: 0;
}
button {
  text-align: center;
  display: inline-block;
  top: 25px;
  border-radius: 5px;
  font-size: 1.5em;
  padding: 10px 27px;
  background: transparent;
  border: 2px solid white;
  color: white;
  transition: all 0.2s ease;
  font-weight: 500;
  font-family: 'Ubuntu', sans-serif;
}
button:hover, button:focus-visible {
  background: white;
  color: #16a085;
  border-color: #16a085;
}
.ring, .item, .console-outer {
  width:100%;
  height: 100%;
  transform-style: preserve-3d;
  user-select:none;
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
  min-height: 100%; /* Aumentado para mejor visualización */
  height: 100%;
  overflow: hidden;
  margin: auto;
  flex: 0 0 100%;
  max-width: 100%;
  position: relative;
}
.console-outer:after {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(180deg, rgba(0,0,0,1) 0%, rgba(0,0,0,0) 10%, rgba(0,0,0,0) 40%, rgba(0,0,0,0) 60%, rgba(0,0,0,0) 90%, rgba(0,0,0,1) 100%);
  content: " ";
}

.container {
  perspective: 2000px;
  width: 200px;
  height: 200px;
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);
  position: relative;
}
ul {
  list-style: none;
  padding: 0;
}
.item {
  position: absolute;
  width: 100%;
  height: 47%;
  display: flex;
  justify-content: center;
  align-items: center;
  background: white;
  border: 1px solid #ccc;
  border-radius: 5px;
  transform-origin: 50% 50% -100px;
  backface-visibility: visible;
  opacity: 0.9;
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

.results {
  width: 100%;
  display: flex;
  justify-content: center;
  flex-direction: column;
  position: relative;
}
.results div {
  font-size: 20px;
  text-align: center;
  color: white;
}
.stage.notstarted .active {
  box-shadow: none;
}
.arrow-indicator {
  position: absolute;
  top: 40%;
  left: 15%;
  transform: translate(-50%, -50%) rotate(90deg);
  width: 0; 
  height: 0; 
  border-left: 15px solid transparent;
  border-right: 15px solid transparent;
  border-bottom: 25px solid yellow;
  z-index: 100;
  pointer-events: none;
}
</style>