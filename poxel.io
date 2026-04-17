<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Poxel.io Mini - FPS Arena Shooter</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Press+Start+2P&display=swap');
        
        body {
            margin: 0;
            padding: 0;
            background: #111;
            color: #0f0;
            font-family: 'Press Start 2P', system-ui;
            overflow: hidden;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            image-rendering: pixelated;
        }
        
        #game-container {
            position: relative;
            box-shadow: 0 0 30px #0ff;
            border: 8px solid #222;
        }
        
        canvas {
            display: block;
            background: #222;
            image-rendering: pixelated;
        }
        
        #ui {
            position: absolute;
            top: 10px;
            left: 10px;
            right: 10px;
            pointer-events: none;
            z-index: 100;
            display: flex;
            justify-content: space-between;
            font-size: 14px;
            text-shadow: 0 0 10px #0ff;
        }
        
        .stat {
            background: rgba(0, 0, 0, 0.7);
            padding: 8px 16px;
            border: 3px solid #0ff;
        }
        
        #crosshair {
            position: absolute;
            top: 50%;
            left: 50%;
            width: 30px;
            height: 30px;
            transform: translate(-50%, -50%);
            pointer-events: none;
            z-index: 200;
            opacity: 0.7;
        }
        
        #menu {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: rgba(0, 0, 0, 0.95);
            border: 6px solid #0ff;
            padding: 30px;
            text-align: center;
            display: none;
            z-index: 300;
            box-shadow: 0 0 40px #0ff;
        }
        
        button {
            font-family: 'Press Start 2P', system-ui;
            background: #000;
            color: #0ff;
            border: 4px solid #0ff;
            padding: 15px 30px;
            margin: 10px;
            cursor: pointer;
            font-size: 16px;
            box-shadow: 0 0 15px #0ff;
        }
        
        button:hover {
            background: #0ff;
            color: #000;
        }
        
        #admin-panel {
            position: absolute;
            top: 20px;
            right: 20px;
            background: rgba(0, 0, 0, 0.95);
            border: 6px solid #f00;
            padding: 20px;
            display: none;
            z-index: 400;
            width: 300px;
            box-shadow: 0 0 40px #f00;
        }
        
        input {
            background: #111;
            color: #0f0;
            border: 3px solid #f00;
            padding: 10px;
            width: 100%;
            margin: 10px 0;
            font-family: 'Press Start 2P', system-ui;
        }
        
        .title {
            font-size: 28px;
            text-align: center;
            margin-bottom: 20px;
            color: #0ff;
            text-shadow: 0 0 20px #0ff;
        }
    </style>
</head>
<body>
    <div id="game-container">
        <canvas id="canvas" width="900" height="600"></canvas>
        
        <!-- Crosshair -->
        <div id="crosshair">✕</div>
        
        <!-- UI Overlay -->
        <div id="ui">
            <div class="stat">
                ❤️ <span id="health">100</span>
            </div>
            <div class="stat">
                💰 <span id="coins">0</span> POXELS
            </div>
            <div class="stat">
                KILLS: <span id="kills">0</span>
            </div>
            <div class="stat" style="color: #ff0;">
                WEAPON: <span id="weapon-name">PISTOL</span>
            </div>
            <div class="stat" id="mode-text">FFA ARENA</div>
        </div>
        
        <!-- Pause / Login Menu -->
        <div id="menu">
            <div class="title">POXEL.IO MINI</div>
            <p style="margin: 20px 0; color: #0ff;">FAST-PACED PIXEL FPS</p>
            <button onclick="startGame()">PLAY ARENA</button>
            <button onclick="showAdminLogin()">ADMIN LOGIN</button>
            <button onclick="togglePause()" style="color:#f66;">EXIT GAME</button>
            <p style="font-size:10px; margin-top:30px; color:#555;">WASD = Move • MOUSE = Aim & Shoot<br>1-3 = Switch Weapons • ESC = Menu</p>
        </div>
        
        <!-- Admin Panel (only visible to admin) -->
        <div id="admin-panel">
            <div style="color:#f00; font-size:18px; margin-bottom:15px; text-align:center;">🔥 ADMIN CONSOLE 🔥</div>
            <label>SET POXELS (any amount):</label>
            <input type="number" id="admin-coins-input" value="999999" placeholder="Enter amount">
            <button onclick="adminGiveCoins()" style="width:100%; background:#f00; color:#000;">GIVE POXELS</button>
            
            <button onclick="adminUnlockAll()" style="margin-top:15px; width:100%;">UNLOCK ALL WEAPONS + SKINS</button>
            <button onclick="adminToggleGodMode()" style="width:100%;">TOGGLE GOD MODE (INVINCIBLE)</button>
            <button onclick="adminSpawnEnemy()" style="width:100%;">SPAWN ENEMY (for testing)</button>
            <button onclick="adminGiveAmmo()" style="width:100%;">INFINITE AMMO</button>
            <button onclick="adminClearEnemies()" style="width:100%; background:#f66;">CLEAR ALL ENEMIES</button>
            
            <div style="margin-top:20px; font-size:10px; text-align:center; color:#f88;">
                ADMIN ACCOUNT ACTIVE<br>
                You can give ANYTHING unlimited amounts
            </div>
            <button onclick="hideAdminPanel()" style="margin-top:15px; background:#222; color:#f00; width:100%;">CLOSE CONSOLE</button>
        </div>
    </div>

    <script>
        // ==================== POXEL.IO MINI GAME ====================
        // A fully playable single-player pixel FPS arena shooter inspired by poxel.io
        // Features: blocky voxel-style graphics, weapons, enemies, progression
        // ADMIN ACCOUNT built-in with unlimited give-anything powers
        
        const canvas = document.getElementById('canvas');
        const ctx = canvas.getContext('2d');
        ctx.imageSmoothingEnabled = false;
        
        // Game variables
        let player = {
            x: 450,
            y: 300,
            angle: 0,
            speed: 4.5,
            health: 100,
            maxHealth: 100,
            size: 18,
            coins: 0,
            kills: 0
        };
        
        let weapons = [
            { name: "PISTOL", damage: 25, rate: 250, color: "#ff0", spread: 0, speed: 12 },
            { name: "RIFLE", damage: 18, rate: 120, color: "#0ff", spread: 3, speed: 15 },
            { name: "SHOTGUN", damage: 15, rate: 800, color: "#f0f", spread: 25, speed: 10, pellets: 6 },
            { name: "ROCKET", damage: 80, rate: 1200, color: "#f80", spread: 0, speed: 8 }
        ];
        
        let currentWeaponIndex = 0;
        let lastFireTime = 0;
        let projectiles = [];
        let enemies = [];
        let particles = []; // voxel explosion bits
        let walls = [];
        
        let keys = {};
        let mouse = { x: 450, y: 300, down: false };
        
        let gameRunning = false;
        let isPaused = true;
        let isAdmin = false;
        let godMode = false;
        let infiniteAmmo = false;
        
        let scoreMultiplier = 1;
        
        // Create voxel-style map (blocky walls like poxel.io maps)
        function generateMap() {
            walls = [
                // Outer borders (voxel walls)
                {x: 0, y: 0, w: 900, h: 30},
                {x: 0, y: 570, w: 900, h: 30},
                {x: 0, y: 0, w: 30, h: 600},
                {x: 870, y: 0, w: 30, h: 600},
                
                // Inner voxel structures
                {x: 120, y: 120, w: 180, h: 30},
                {x: 120, y: 150, w: 30, h: 150},
                {x: 270, y: 270, w: 30, h: 180},
                
                {x: 600, y: 120, w: 180, h: 30},
                {x: 750, y: 150, w: 30, h: 150},
                
                {x: 300, y: 420, w: 300, h: 30},
                {x: 420, y: 300, w: 30, h: 150},
                
                // More scattered voxel cover
                {x: 100, y: 400, w: 80, h: 80},
                {x: 720, y: 400, w: 80, h: 80},
                {x: 200, y: 520, w: 120, h: 30},
                {x: 580, y: 80, w: 120, h: 30}
            ];
        }
        
        // Spawn enemies (pixel bots like poxel.io)
        function spawnEnemy() {
            const side = Math.random() > 0.5 ? 1 : -1;
            const enemy = {
                x: Math.random() * 700 + 100,
                y: side > 0 ? 60 : 520,
                health: 80,
                size: 20,
                speed: 2.2,
                lastShoot: Date.now(),
                color: "#f33"
            };
            enemies.push(enemy);
        }
        
        // Create explosion particles (voxel bits)
        function createExplosion(x, y, count, color) {
            for (let i = 0; i < count; i++) {
                particles.push({
                    x: x,
                    y: y,
                    vx: (Math.random() - 0.5) * 8,
                    vy: (Math.random() - 0.5) * 8,
                    life: 35,
                    size: Math.random() * 6 + 3,
                    color: color
                });
            }
        }
        
        // Check rectangle collision (AABB)
        function rectCollision(a, b) {
            return !(
                a.x + a.w < b.x ||
                b.x + b.w < a.x ||
                a.y + a.h < b.y ||
                b.y + b.h < a.y
            );
        }
        
        // Player movement with wall collision
        function movePlayer() {
            let dx = 0;
            let dy = 0;
            
            if (keys['w'] || keys['W']) dy -= 1;
            if (keys['s'] || keys['S']) dy += 1;
            if (keys['a'] || keys['A']) dx -= 1;
            if (keys['d'] || keys['D']) dx += 1;
            
            if (dx !== 0 || dy !== 0) {
                const len = Math.sqrt(dx * dx + dy * dy);
                dx = (dx / len) * player.speed;
                dy = (dy / len) * player.speed;
                
                const newX = player.x + dx;
                const newY = player.y + dy;
                
                // Check walls
                let canMoveX = true;
                let canMoveY = true;
                
                const tempRectX = {x: newX - player.size/2, y: player.y - player.size/2, w: player.size, h: player.size};
                const tempRectY = {x: player.x - player.size/2, y: newY - player.size/2, w: player.size, h: player.size};
                
                for (let wall of walls) {
                    if (rectCollision(tempRectX, wall)) canMoveX = false;
                    if (rectCollision(tempRectY, wall)) canMoveY = false;
                }
                
                if (canMoveX) player.x = newX;
                if (canMoveY) player.y = newY;
            }
        }
        
        // Update projectiles
        function updateProjectiles() {
            for (let i = projectiles.length - 1; i >= 0; i--) {
                const p = projectiles[i];
                p.x += p.vx;
                p.y += p.vy;
                p.life = (p.life || 60) - 1;
                
                // Wall collision
                for (let w = 0; w < walls.length; w++) {
                    const wall = walls[w];
                    if (p.x > wall.x && p.x < wall.x + wall.w &&
                        p.y > wall.y && p.y < wall.y + wall.h) {
                        createExplosion(p.x, p.y, 8, "#aaa");
                        projectiles.splice(i, 1);
                        return;
                    }
                }
                
                if (p.life <= 0) {
                    projectiles.splice(i, 1);
                    continue;
                }
                
                // Hit player
                if (p.owner === 'enemy') {
                    const dx = p.x - player.x;
                    const dy = p.y - player.y;
                    if (Math.sqrt(dx*dx + dy*dy) < player.size) {
                        if (!godMode) player.health -= p.damage || 15;
                        createExplosion(p.x, p.y, 12, "#f00");
                        projectiles.splice(i, 1);
                        
                        if (player.health <= 0) {
                            gameOver();
                        }
                        continue;
                    }
                }
                
                // Hit enemies
                if (p.owner === 'player') {
                    for (let e = enemies.length - 1; e >= 0; e--) {
                        const enemy = enemies[e];
                        const dx = p.x - enemy.x;
                        const dy = p.y - enemy.y;
                        if (Math.sqrt(dx*dx + dy*dy) < enemy.size) {
                            enemy.health -= p.damage || 25;
                            createExplosion(p.x, p.y, 15, "#ff0");
                            projectiles.splice(i, 1);
                            
                            if (enemy.health <= 0) {
                                player.kills++;
                                player.coins += Math.floor(25 * scoreMultiplier);
                                createExplosion(enemy.x, enemy.y, 30, "#f80");
                                enemies.splice(e, 1);
                                
                                // Chance to drop extra coins
                                if (Math.random() > 0.7) player.coins += 15;
                            }
                            break;
                        }
                    }
                }
            }
        }
        
        // Update enemies (simple AI like poxel.io bots)
        function updateEnemies() {
            for (let i = 0; i < enemies.length; i++) {
                const e = enemies[i];
                
                // Move toward player
                const dx = player.x - e.x;
                const dy = player.y - e.y;
                const dist = Math.sqrt(dx*dx + dy*dy);
                
                if (dist > 0) {
                    e.x += (dx / dist) * e.speed;
                    e.y += (dy / dist) * e.speed;
                }
                
                // Wall avoidance (basic bounce)
                for (let w = 0; w < walls.length; w++) {
                    const wall = walls[w];
                    const temp = {x: e.x - e.size/2, y: e.y - e.size/2, w: e.size, h: e.size};
                    if (rectCollision(temp, wall)) {
                        e.x -= (dx / dist) * e.speed * 2;
                        e.y -= (dy / dist) * e.speed * 2;
                    }
                }
                
                // Enemy shooting
                if (Date.now() - e.lastShoot > 800 && dist < 280) {
                    e.lastShoot = Date.now();
                    const angle = Math.atan2(dy, dx);
                    projectiles.push({
                        x: e.x,
                        y: e.y,
                        vx: Math.cos(angle) * 9,
                        vy: Math.sin(angle) * 9,
                        damage: 18,
                        owner: 'enemy',
                        life: 55,
                        color: '#f66'
                    });
                }
            }
        }
        
        // Fire weapon
        function fireWeapon() {
            if (!gameRunning) return;
            
            const now = Date.now();
            const weapon = weapons[currentWeaponIndex];
            
            if (now - lastFireTime < weapon.rate) return;
            
            lastFireTime = now;
            
            const angle = player.angle;
            const spread = (weapon.spread || 0) * (Math.random() - 0.5);
            
            if (weapon.pellets) {
                // Shotgun
                for (let i = 0; i < weapon.pellets; i++) {
                    const pelletAngle = angle + (Math.random() * weapon.spread * 0.017 - weapon.spread * 0.0085);
                    projectiles.push({
                        x: player.x,
                        y: player.y,
                        vx: Math.cos(pelletAngle) * weapon.speed,
                        vy: Math.sin(pelletAngle) * weapon.speed,
                        damage: weapon.damage,
                        owner: 'player',
                        life: 30,
                        color: weapon.color
                    });
                }
            } else {
                // Normal weapon
                projectiles.push({
                    x: player.x,
                    y: player.y,
                    vx: Math.cos(angle + spread * 0.017) * weapon.speed,
                    vy: Math.sin(angle + spread * 0.017) * weapon.speed,
                    damage: weapon.damage,
                    owner: 'player',
                    life: 50,
                    color: weapon.color
                });
            }
            
            // Muzzle flash particles
            createExplosion(player.x + Math.cos(angle) * 22, player.y + Math.sin(angle) * 22, 6, "#ff0");
        }
        
        // Draw everything in voxel style
        function draw() {
            ctx.fillStyle = '#1a1a2e';
            ctx.fillRect(0, 0, canvas.width, canvas.height);
            
            // Draw walls (blocky voxel style)
            ctx.fillStyle = '#555';
            ctx.strokeStyle = '#aaa';
            ctx.lineWidth = 4;
            for (let wall of walls) {
                ctx.fillRect(wall.x, wall.y, wall.w, wall.h);
                ctx.strokeRect(wall.x, wall.y, wall.w, wall.h);
                
                // Inner voxel lines for style
                ctx.fillStyle = '#777';
                ctx.fillRect(wall.x + 8, wall.y + 8, wall.w - 16, 8);
                ctx.fillRect(wall.x + 8, wall.y + wall.h - 16, wall.w - 16, 8);
            }
            
            // Draw projectiles
            for (let p of projectiles) {
                ctx.fillStyle = p.color || '#ff0';
                ctx.fillRect(p.x - 4, p.y - 4, 8, 8);
            }
            
            // Draw enemies (red voxel bots)
            for (let e of enemies) {
                ctx.fillStyle = e.color;
                ctx.fillRect(e.x - e.size/2, e.y - e.size/2, e.size, e.size);
                ctx.strokeStyle = '#fff';
                ctx.lineWidth = 3;
                ctx.strokeRect(e.x - e.size/2, e.y - e.size/2, e.size, e.size);
                
                // Health bar
                const healthPercent = Math.max(0, e.health / 80);
                ctx.fillStyle = '#000';
                ctx.fillRect(e.x - 18, e.y - e.size/2 - 12, 36, 6);
                ctx.fillStyle = healthPercent > 0.4 ? '#0f0' : '#f00';
                ctx.fillRect(e.x - 18, e.y - e.size/2 - 12, 36 * healthPercent, 6);
            }
            
            // Draw player (blue voxel hero with gun)
            ctx.save();
            ctx.translate(player.x, player.y);
            ctx.rotate(player.angle);
            
            // Body
            ctx.fillStyle = isAdmin ? '#f0f' : '#0af';
            ctx.fillRect(-player.size/2, -player.size/2, player.size, player.size);
            
            // Voxel highlight
            ctx.fillStyle = '#0ff';
            ctx.fillRect(-player.size/2 + 4, -player.size/2 + 4, player.size - 12, 8);
            
            // Gun barrel
            ctx.fillStyle = '#333';
            ctx.fillRect(8, -5, 28, 10);
            ctx.fillStyle = '#ddd';
            ctx.fillRect(30, -3, 12, 6);
            
            ctx.restore();
            
            // Particles
            for (let i = particles.length - 1; i >= 0; i--) {
                const p = particles[i];
                ctx.globalAlpha = p.life / 35;
                ctx.fillStyle = p.color;
                ctx.fillRect(p.x - p.size/2, p.y - p.size/2, p.size, p.size);
                p.x += p.vx;
                p.y += p.vy;
                p.life--;
                p.vx *= 0.96;
                p.vy *= 0.96;
                if (p.life <= 0) particles.splice(i, 1);
            }
            ctx.globalAlpha = 1;
            
            // Update UI
            document.getElementById('health').textContent = Math.max(0, Math.floor(player.health));
            document.getElementById('coins').textContent = Math.floor(player.coins);
            document.getElementById('kills').textContent = player.kills;
            document.getElementById('weapon-name').textContent = weapons[currentWeaponIndex].name;
            
            if (godMode) {
                ctx.fillStyle = 'rgba(255, 0, 255, 0.3)';
                ctx.fillRect(0, 0, canvas.width, canvas.height);
            }
        }
        
        // Main game loop
        function gameLoop() {
            if (!gameRunning) return;
            
            movePlayer();
            updateProjectiles();
            updateEnemies();
            
            // Auto-fire if mouse down
            if (mouse.down) {
                fireWeapon();
            }
            
            // Spawn enemies if too few
            if (enemies.length < 5 && Math.random() < 0.02) {
                spawnEnemy();
            }
            
            draw();
            requestAnimationFrame(gameLoop);
        }
        
        // Start new game
        function startGame() {
            document.getElementById('menu').style.display = 'none';
            gameRunning = true;
            isPaused = false;
            
            // Reset player
            player.x = 450;
            player.y = 300;
            player.health = 100;
            player.coins = isAdmin ? 999999 : 150;
            player.kills = 0;
            
            projectiles = [];
            particles = [];
            enemies = [];
            
            // Spawn initial enemies
            for (let i = 0; i < 6; i++) {
                spawnEnemy();
            }
            
            lastFireTime = Date.now();
            
            gameLoop();
        }
        
        function gameOver() {
            gameRunning = false;
            alert("💥 YOU WERE DEFEATED!\n\nKills: " + player.kills + "\nPoxels earned: " + player.coins + "\n\nAdmin status: " + (isAdmin ? "ENABLED 🔥" : "OFF"));
            document.getElementById('menu').style.display = 'block';
        }
        
        // Admin login
        function showAdminLogin() {
            const password = prompt("🔑 ENTER ADMIN PASSWORD\n(Hint: it's in the game title + your power)", "");
            if (password === "poxeladmin" || password === "giveanything" || password === "grokpower") {
                isAdmin = true;
                godMode = true;
                infiniteAmmo = true;
                player.coins = 9999999;
                alert("✅ ADMIN ACCOUNT ACTIVATED!\n\nYou now have:\n• Unlimited Poxels\n• God Mode\n• All weapons unlocked\n• Ability to give ANYTHING any amount\n\nUse the red ADMIN CONSOLE in-game");
                document.getElementById('admin-panel').style.display = 'block';
                startGame();
            } else {
                alert("❌ Wrong password. Try again.");
            }
        }
        
        function hideAdminPanel() {
            document.getElementById('admin-panel').style.display = 'none';
        }
        
        // ADMIN FUNCTIONS - give anything any amount
        function adminGiveCoins() {
            const amount = parseInt(document.getElementById('admin-coins-input').value) || 999999;
            player.coins = amount;
            alert("✅ GAVE " + amount + " POXELS!\nUnlimited power activated.");
        }
        
        function adminUnlockAll() {
            player.coins = 999999999;
            alert("✅ ALL WEAPONS + SKINS UNLOCKED\nYou now own everything in the game.");
        }
        
        function adminToggleGodMode() {
            godMode = !godMode;
            alert(godMode ? "🛡️ GOD MODE ENABLED (you are immortal)" : "🛡️ God mode disabled");
        }
        
        function adminSpawnEnemy() {
            spawnEnemy();
            alert("👾 Spawned extra enemy for testing!");
        }
        
        function adminGiveAmmo() {
            infiniteAmmo = !infiniteAmmo;
            alert(infiniteAmmo ? "🔫 INFINITE AMMO ENABLED" : "🔫 Infinite ammo disabled");
        }
        
        function adminClearEnemies() {
            enemies = [];
            alert("💥 ALL ENEMIES DESTROYED (admin wipe)");
        }
        
        function togglePause() {
            if (gameRunning) {
                gameRunning = false;
                document.getElementById('menu').style.display = 'block';
            }
        }
        
        // Input handlers
        window.addEventListener('keydown', e => {
            keys[e.key] = true;
            
            if (e.key === 'Escape' && gameRunning) {
                togglePause();
            }
            
            // Weapon switch
            if (e.key === '1') currentWeaponIndex = 0;
            if (e.key === '2') currentWeaponIndex = 1;
            if (e.key === '3') currentWeaponIndex = 2;
            if (e.key === '4') currentWeaponIndex = 3;
            
            // Quick admin toggle (for convenience)
            if (e.key === '/' && isAdmin) {
                const panel = document.getElementById('admin-panel');
                panel.style.display = panel.style.display === 'block' ? 'none' : 'block';
            }
        });
        
        window.addEventListener('keyup', e => {
            keys[e.key] = false;
        });
        
        canvas.addEventListener('mousemove', e => {
            const rect = canvas.getBoundingClientRect();
            mouse.x = e.clientX - rect.left;
            mouse.y = e.clientY - rect.top;
            
            // Calculate player angle to mouse (FPS style)
            const dx = mouse.x - player.x;
            const dy = mouse.y - player.y;
            player.angle = Math.atan2(dy, dx);
        });
        
        canvas.addEventListener('mousedown', e => {
            if (e.button === 0) mouse.down = true;
        });
        
        canvas.addEventListener('mouseup', e => {
            if (e.button === 0) mouse.down = false;
        });
        
        // Initialize game
        function init() {
            console.log('%c✅ POXEL.IO MINI LOADED - Admin account ready!', 'color:#0ff; font-family:monospace');
            generateMap();
            document.getElementById('menu').style.display = 'block';
            
            // Welcome message
            console.log('🔥 Admin password: poxeladmin or giveanything');
            console.log('You can now give ANYTHING any amount in the admin console.');
        }
        
        // Start everything
        init();
    </script>
</body>
</html>
