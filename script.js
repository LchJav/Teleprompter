const scrollArea = document.getElementById('scrollArea');
const scriptText = document.getElementById('scriptText');
const stage = document.getElementById('stage');
const playBtn = document.getElementById('playBtn');
const stopBtn = document.getElementById('stopBtn');
const editBtn = document.getElementById('editBtn');
const doneEditBtn = document.getElementById('doneEditBtn');
const editArea = document.getElementById('editArea');
const scriptInput = document.getElementById('scriptInput');
const speedInput = document.getElementById('speed');
const fontSizeInput = document.getElementById('fontSize');
const mirrorInput = document.getElementById('mirror');
const hideBtn = document.getElementById('hideBtn');
const helpBtn = document.getElementById('helpBtn');
const helpPanel = document.getElementById('helpPanel');
const helpClose = document.getElementById('helpClose');

const colorBtn = document.getElementById('colorBtn');
const colorMenu = document.getElementById('colorMenu');

colorBtn.addEventListener('click', (e) => {
  e.stopPropagation();
  colorMenu.classList.toggle('show');
});

colorMenu.querySelectorAll('.swatchRow').forEach(row => {
  row.addEventListener('click', () => {
    document.documentElement.style.setProperty('--accent', row.dataset.color);
    colorMenu.querySelectorAll('.swatchRow').forEach(r => r.classList.remove('active'));
    row.classList.add('active');
    colorMenu.classList.remove('show');
  });
});

document.addEventListener('click', () => {
  colorMenu.classList.remove('show');
});

colorMenu.querySelector('[data-color="#3fb8a6"]').classList.add('active');

helpBtn.addEventListener('click', (e) => {
  e.stopPropagation();
  helpPanel.classList.toggle('show');
});
helpClose.addEventListener('click', () => {
  helpPanel.classList.remove('show');
});
document.addEventListener('click', (e) => {
  if(helpPanel.classList.contains('show') && !helpPanel.contains(e.target)){
    helpPanel.classList.remove('show');
  }
});
const topbar = document.getElementById('topbar');
const camPos = document.getElementById('camPos');
const camLine = document.getElementById('camLine');
const sideBtn = document.getElementById('sideBtn');
const speedOut = document.getElementById('speedOut');
const textWidthInput = document.getElementById('textWidth');
const readPos = document.getElementById('readPos');
const readLine = document.getElementById('readLine');

readPos.addEventListener('input', () => {
  readLine.style.top = readPos.value + '%';
});
readLine.style.top = readPos.value + '%';

const linesToggle = document.getElementById('linesToggle');
linesToggle.addEventListener('change', () => {
  camLine.classList.toggle('hidden-line', !linesToggle.checked);
  readLine.classList.toggle('hidden-line', !linesToggle.checked);
});

textWidthInput.addEventListener('input', () => {
  scriptText.style.maxWidth = textWidthInput.value + '%';
});
scriptText.style.maxWidth = textWidthInput.value + '%';

const speedManual = document.getElementById('speedManual');

const speedLevels = [0.7, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5];

let manualSpeed = null;

function currentSpeed(){
  if(manualSpeed !== null) return manualSpeed;
  return speedLevels[parseInt(speedInput.value, 10)];
}

speedInput.addEventListener('input', () => {
  manualSpeed = null;
  const val = currentSpeed();
  speedOut.textContent = val;
  speedManual.value = val;
});

speedManual.addEventListener('input', () => {
  const v = parseFloat(speedManual.value);
  if(!isNaN(v) && v > 0){
    manualSpeed = v;
    speedOut.textContent = v;
  }
});

let playing = false;
let posY = 0;
let nudgeOffset = 0;
let rafId = null;
let side = 'left';
const sideLabels = {left:'Cámara: izquierda ⇄', right:'Cámara: derecha ⇄', center:'Cámara: centro ⇄'};
const sideOrder = ['left','right','center'];

function updateCamLine(){
  const dist = camPos.value + '%';
  scriptText.classList.remove('side-right');
  if(side === 'left'){
    camLine.style.left = dist;
    camLine.style.right = 'auto';
    scriptText.style.marginLeft = '0';
    scriptText.style.marginRight = 'auto';
  } else if(side === 'right'){
    camLine.style.right = dist;
    camLine.style.left = 'auto';
    scriptText.classList.add('side-right');
    scriptText.style.marginLeft = 'auto';
    scriptText.style.marginRight = '0';
  } else {
    camLine.style.left = '50%';
    camLine.style.right = 'auto';
    scriptText.style.textAlign = 'center';
    scriptText.style.marginLeft = 'auto';
    scriptText.style.marginRight = 'auto';
  }
}
camPos.addEventListener('input', updateCamLine);

const sideMenu = document.getElementById('sideMenu');

function setSide(newSide){
  side = newSide;
  sideBtn.textContent = sideLabels[side].replace('⇄','▾');
  if(side !== 'center') scriptText.style.textAlign = (side === 'right') ? 'right' : 'left';
  updateCamLine();
  sideMenu.querySelectorAll('button').forEach(b => {
    b.classList.toggle('active', b.dataset.side === side);
  });
}

sideBtn.addEventListener('click', (e) => {
  e.stopPropagation();
  sideMenu.classList.toggle('show');
});

sideMenu.querySelectorAll('button').forEach(b => {
  b.addEventListener('click', () => {
    setSide(b.dataset.side);
    sideMenu.classList.remove('show');
  });
});

document.addEventListener('click', () => {
  sideMenu.classList.remove('show');
});

setSide(side);

function tick(){
  if(playing){
    posY -= currentSpeed() * 0.6;

    const paddingBottom = parseFloat(window.getComputedStyle(scriptText).paddingBottom) || (window.innerHeight * 0.9);
    const textBottom = scrollArea.offsetHeight - paddingBottom;
    const readLineY = stage.offsetHeight * (parseFloat(readPos.value) / 100);

    if (-posY >= (textBottom - readLineY + 60)) {
      stopBtn.click();
    }
  }
  if(Math.abs(nudgeOffset) > 0.5){
    const move = nudgeOffset * 0.18;
    posY += move;
    nudgeOffset -= move;
  } else {
    nudgeOffset = 0;
  }
  scrollArea.style.transform = 'translateY(' + posY + 'px)';
  rafId = requestAnimationFrame(tick);
}
tick();

const statusIndicator = document.getElementById('statusIndicator');

playBtn.addEventListener('click', () => {
  playing = !playing;
  playBtn.textContent = playing ? '⏸ Pausar' : '▶ Iniciar';
  statusIndicator.classList.toggle('playing', playing);
});

stopBtn.addEventListener('click', () => {
  posY = 0;
  nudgeOffset = 0;
  scrollArea.style.transform = 'translateY(0px)';
  playing = false;
  playBtn.textContent = '▶ Iniciar';
  statusIndicator.classList.remove('playing');
});

fontSizeInput.addEventListener('input', () => {
  scriptText.style.fontSize = fontSizeInput.value + 'px';
});

mirrorInput.addEventListener('change', () => {
  stage.style.transform = mirrorInput.checked ? 'scaleX(-1)' : 'none';
});

editBtn.addEventListener('click', () => {
  scriptInput.value = scriptText.textContent.trim();
  editArea.classList.add('show');
  playing = false;
  playBtn.textContent = '▶ Iniciar';
  statusIndicator.classList.remove('playing');
});

doneEditBtn.addEventListener('click', () => {
  scriptText.textContent = scriptInput.value;
  editArea.classList.remove('show');
  posY = 0;
  scrollArea.style.transform = 'translateY(0px)';
});

const showControlsBtn = document.getElementById('showControlsBtn');

hideBtn.addEventListener('click', () => {
  topbar.classList.add('hidden');
  showControlsBtn.classList.add('show');
});

showControlsBtn.addEventListener('click', () => {
  topbar.classList.remove('hidden');
  showControlsBtn.classList.remove('show');
});

document.addEventListener('keydown', (e) => {
  if(editArea.classList.contains('show')) return;
  if(e.code === 'Space'){
    e.preventDefault();
    playing = !playing;
    playBtn.textContent = playing ? '⏸ Pausar' : '▶ Iniciar';
    statusIndicator.classList.toggle('playing', playing);
  }
  if(e.code === 'ArrowUp'){
    e.preventDefault();
    nudgeOffset += 70;
  }
  if(e.code === 'ArrowDown'){
    e.preventDefault();
    nudgeOffset -= 70;
  }
  if(e.code === 'ArrowRight'){
    e.preventDefault();
    manualSpeed = null;
    speedInput.value = Math.min(8, parseInt(speedInput.value, 10) + 1);
    const val = currentSpeed();
    speedOut.textContent = val;
    speedManual.value = val;
  }
  if(e.code === 'ArrowLeft'){
    e.preventDefault();
    manualSpeed = null;
    speedInput.value = Math.max(0, parseInt(speedInput.value, 10) - 1);
    const val = currentSpeed();
    speedOut.textContent = val;
    speedManual.value = val;
  }
  if(e.code === 'KeyH'){
    topbar.classList.toggle('hidden');
    showControlsBtn.classList.toggle('show', topbar.classList.contains('hidden'));
  }
  if(e.code === 'KeyS'){
    stopBtn.click();
  }
  if(e.code === 'KeyD'){
    editBtn.click();
  }
});
