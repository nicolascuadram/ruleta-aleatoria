<template>
  <div class="stage notstarted">
    <div class="wheel-system">
      <div class="row console">
        <div class="console-outer">
          <div id="col1" class="col third wheel">
            <div class="wheel-container">
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
      seed: Date.now(),
      items: ['Organizacional','Operativo','Tecnológico','Proyecto','Personal',
              'Organizacional','Operativo','Tecnológico','Proyecto','Personal']
    }
  },
  mounted() {
    this.initGame();
  },
  methods: {
    xorshift() {
      let x = this.seed >>> 0;
      x ^= x << 13;
      x ^= x >> 17;
      x ^= x << 5;
      this.seed = x >>> 0;
      return this.seed;
    },
    
    initGame() {
      const anglePerItem = 360 / this.items.length; // Usar el mismo valor en todas partes

      gsap.set(".ring", { rotationX: -270 });
      gsap.set(".item", {
        rotateX: (i) => (i * -anglePerItem),
        transformOrigin: "50% 50% -200px",
        z: 200,
      });

      document.querySelector('button.trigger').addEventListener('click', this.spinWheels);
    },
    
    spinWheels() {
      const itemCount = this.items.length;
      const anglePerItem = (360 / itemCount);

      // Número de vueltas (1-10)
      const fullRotations = (this.xorshift() % 10) + 1;
      
      // Ítem aleatorio como destino final
      const targetIndex = Math.floor(this.xorshift() % itemCount);
      console.log(targetIndex);
      // Ángulo final con compensación
      const targetAngle = (fullRotations * 360 + (targetIndex * anglePerItem));
      
      // Mostrar información
      const textcontent = document.getElementById('textcontent');
      textcontent.innerHTML = `<p>Girando...</p>`;
      
      // Preparar animación
      document.querySelector('.stage').classList.remove('notstarted');
      document.querySelectorAll('.ring .item').forEach(item => {
        item.classList.remove('active');
      });

      // Animación GSAP
      gsap.to('#ring1', {
        rotationX: targetAngle,
        duration: 2 + fullRotations * 0.3,
        ease: 'power3.out',
        onComplete: this.finishScroll
      });
    },
    
    finishScroll() {
      const ring = document.querySelector('#ring1');
      const items = ring.querySelectorAll('.item');
      const itemCount = items.length;
      const anglePerItem = 360 / itemCount;
      
      // Obtener y normalizar rotación (0-360)
      let rotation = (gsap.getProperty(ring, "rotationX") % 360 + 360) % 360;
      
      // Compensación visual (ajustar según necesidad)
      const visualOffset = anglePerItem / 2; // Punto medio del ítem
      const normalizedAngle = (rotation + visualOffset) % 360;
      const winningIndex = Math.floor(normalizedAngle / anglePerItem) % itemCount;
      
      // Seleccionar ganador
      const winningItem = items[winningIndex];
      const textcontent = document.getElementById('textcontent');
      
      // Dentro de finishScroll()
      if (winningItem) {
        const resultado = winningItem.dataset.content;

        // Enviar resultado al backend
        fetch('http://localhost:3000/api/ruleta', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ resultado })
        })
        .then(res => {
          if (!res.ok) {
            throw new Error('Error al guardar el resultado');
          }
          return res.json();
        })
        .then(data => {
          console.log('Resultado guardado:', data);
        })
        .catch(err => {
          console.error('Error de red o servidor:', err);
        });


        // Mostrar resultado en consola
        console.log('Resultado enviado:', resultado);

        textcontent.innerHTML = `<p>Resultado: ${resultado}</p>`;
        items.forEach(item => item.classList.remove('active'));
        winningItem.classList.add('active');
        
        gsap.to(winningItem, {
          scale: 1.1,
          duration: 0.5,
          yoyo: true,
          repeat: 1
        });
      }
    }
  }
}
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

.ring, .item, .console-outer {
  width: 100%;
  height: 100%;
  transform-style: preserve-3d;
  user-select: none;
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
  height: 65%;
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

.stage.notstarted .active {
  box-shadow: none;
}
</style>