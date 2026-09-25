$content = Get-Content -Path "index.html" -Raw

$cssRegex = '(?s)/\*\s*══════════════════\s*REALISTIC BACKGROUND\s*══════════════════\s*\*/.*?@keyframes slowPan \{.*?\}\r?\n'
$content = $content -replace $cssRegex, ''

$htmlOld = '<div class="galaxy-bg"></div>'
$content = $content.Replace($htmlOld, '')

$jsOldRegex = '(?s)/\*\s*══════════════════════════════════════════════════\r?\n\s*BLACK & GOLD GALAXY STARFIELD — Parallax System\r?\n\s*══════════════════════════════════════════════════ \*/\r?\n\(function\(\)\{.*?\r?\n\}\)\(\);\r?\n'

$jsNew = @"
/* ══════════════════════════════════════════════════
   ULTRA-REALISTIC GALAXY & TWINKLING STARS
   ══════════════════════════════════════════════════ */
(function(){
  const canvas = document.getElementById('galaxy-canvas');
  const ctx = canvas.getContext('2d');
  let W, H;
  let mouseX = 0, mouseY = 0, targetMX = 0, targetMY = 0;
  let scrollY = 0, targetScrollY = 0;

  let stars = [];
  let galaxies = [];
  let shootingStars = [];

  function init(){
    W = canvas.width = window.innerWidth;
    H = canvas.height = window.innerHeight;

    stars = [];
    galaxies = [];

    // Create realistic Milky Way band (diagonal)
    for(let i=0; i<90; i++){
      let gx = Math.random() * W;
      let gy = Math.random() * (H * 2);
      let dist = Math.abs((gx / W) - (gy / (H*2)));
      if (dist > 0.35 && Math.random() > 0.15) continue; // Concentrate in the center diagonal
      
      let radius = Math.random() * 500 + 200;
      let r = Math.floor(Math.random() * 40) + 10;
      let g = Math.floor(Math.random() * 25) + 5;
      let b = Math.floor(Math.random() * 50) + 20;
      
      if(Math.random() > 0.8) { r += 80; g += 60; } // Some golden dust

      galaxies.push({
        x: gx, y: gy, r, g, b, radius,
        dx: (Math.random() - 0.5) * 0.08,
        dy: (Math.random() - 0.5) * 0.08,
        parallaxY: 0.08 + Math.random() * 0.05
      });
    }

    // Thousands of tiny realistic stars
    for(let i=0; i<2000; i++){
      let isBright = Math.random() > 0.95;
      stars.push({
        x: Math.random() * W, y: Math.random() * (H * 2),
        size: isBright ? Math.random() * 1.5 + 0.5 : Math.random() * 0.8 + 0.2,
        twinkleSpeed: 0.005 + Math.random() * 0.03,
        t: Math.random() * Math.PI * 2,
        baseAlpha: isBright ? (0.5 + Math.random() * 0.5) : (0.1 + Math.random() * 0.4),
        parallaxY: 0.15 + Math.random() * 0.15,
        parallaxX: 0.02 + Math.random() * 0.03,
        color: Math.random() > 0.8 ? '255,248,220' : (Math.random() > 0.9 ? '150,200,255' : '255,255,255')
      });
    }
  }

  function drawBackground() {
    let grad = ctx.createLinearGradient(0, 0, 0, H);
    grad.addColorStop(0, '#000000');
    grad.addColorStop(0.5, '#020105');
    grad.addColorStop(1, '#050314');
    ctx.fillStyle = grad;
    ctx.fillRect(0, 0, W, H);
  }

  function drawGalaxies() {
    ctx.globalCompositeOperation = 'screen';
    galaxies.forEach(g => {
      g.x += g.dx;
      g.y += g.dy;
      if (g.x < -g.radius) g.x = W + g.radius;
      if (g.x > W + g.radius) g.x = -g.radius;
      
      let py = g.y - (scrollY * g.parallaxY);
      py = ((py % (H*2.5)) + (H*2.5)) % (H*2.5) - (H*0.25);

      let grad = ctx.createRadialGradient(g.x, py, 0, g.x, py, g.radius);
      grad.addColorStop(0, \`rgba(\` + g.r + \`,\` + g.g + \`,\` + g.b + \`, 0.03)\`);
      grad.addColorStop(0.5, \`rgba(\` + g.r + \`,\` + g.g + \`,\` + g.b + \`, 0.008)\`);
      grad.addColorStop(1, \`rgba(\` + g.r + \`,\` + g.g + \`,\` + g.b + \`, 0)\`);
      
      ctx.fillStyle = grad;
      ctx.beginPath();
      ctx.arc(g.x, py, g.radius, 0, Math.PI * 2);
      ctx.fill();
    });
    ctx.globalCompositeOperation = 'source-over';
  }

  function drawStars() {
    stars.forEach(s => {
      s.t += s.twinkleSpeed;
      let alpha = s.baseAlpha * (0.5 + Math.sin(s.t) * 0.5);
      
      let px = s.x + (mouseX - W/2) * s.parallaxX;
      let py = s.y + (mouseY - H/2) * s.parallaxX - (scrollY * s.parallaxY);
      py = ((py % H) + H) % H;

      ctx.fillStyle = \`rgba(\` + s.color + \`, \` + alpha + \`)\`;
      ctx.beginPath();
      ctx.arc(px, py, s.size, 0, Math.PI * 2);
      ctx.fill();

      if (s.size > 1.2 && alpha > 0.6) {
         ctx.fillStyle = \`rgba(\` + s.color + \`, \` + (alpha * 0.2) + \`)\`;
         ctx.beginPath();
         ctx.arc(px, py, s.size * 3, 0, Math.PI * 2);
         ctx.fill();
      }
    });
  }

  function handleShootingStars(){
    if(Math.random() < 0.003 && shootingStars.length < 2){
      shootingStars.push({
        x: Math.random() * W, y: Math.random() * H * 0.3,
        vx: Math.random() > 0.5 ? (10 + Math.random() * 15) : (-10 - Math.random() * 15),
        vy: 5 + Math.random() * 10,
        len: 60 + Math.random() * 100,
        life: 1
      });
    }

    for(let i = shootingStars.length - 1; i >= 0; i--){
      let ss = shootingStars[i];
      ss.x += ss.vx;
      ss.y += ss.vy;
      ss.life -= 0.015;
      
      if(ss.life <= 0){
        shootingStars.splice(i, 1);
        continue;
      }

      let opacity = Math.max(0, ss.life);
      let tailX = ss.x - ss.vx * (ss.len / 20);
      let tailY = ss.y - ss.vy * (ss.len / 20);

      let grad = ctx.createLinearGradient(ss.x, ss.y, tailX, tailY);
      grad.addColorStop(0, \`rgba(255,255,255,\` + opacity + \`)\`);
      grad.addColorStop(0.1, \`rgba(255,215,0,\` + (opacity * 0.8) + \`)\`);
      grad.addColorStop(1, \`rgba(205,127,50,0)\`);

      ctx.beginPath();
      ctx.strokeStyle = grad;
      ctx.lineWidth = 2;
      ctx.lineCap = 'round';
      ctx.moveTo(ss.x, ss.y);
      ctx.lineTo(tailX, tailY);
      ctx.stroke();
    }
  }

  function draw(){
    drawBackground();
    
    mouseX += (targetMX - mouseX) * 0.05;
    mouseY += (targetMY - mouseY) * 0.05;
    scrollY += (targetScrollY - scrollY) * 0.08;

    drawGalaxies();
    drawStars();
    handleShootingStars();

    requestAnimationFrame(draw);
  }

  document.addEventListener('mousemove', e => {
    targetMX = e.clientX;
    targetMY = e.clientY;
  });
  window.addEventListener('scroll', () => { targetScrollY = window.scrollY; });
  window.addEventListener('resize', init);
  init();
  draw();
})();
"@

$content = $content -replace $jsOldRegex, $jsNew
Set-Content -Path "index.html" -Value $content -Encoding UTF8
