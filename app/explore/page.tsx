'use client';

import { useEffect, useRef, useState } from 'react';
import * as THREE from 'three';
import { getAllPersonas } from '@/lib/personas';
import { useRouter } from 'next/navigation';

export default function ExplorePage() {
  const mountRef = useRef<HTMLDivElement>(null);
  const sceneRef = useRef<THREE.Scene | null>(null);
  const rendererRef = useRef<THREE.WebGLRenderer | null>(null);
  const cameraRef = useRef<THREE.PerspectiveCamera | null>(null);
  const charactersRef = useRef<any[]>([]);
  const playerRef = useRef({
    position: new THREE.Vector3(0, 1.6, 5),
    velocity: new THREE.Vector3(0, 0, 0),
    speed: 0.1,
    isDancing: false
  });
  const keysRef = useRef<Record<string, boolean>>({});
  const mouseXRef = useRef(0);
  const animationIdRef = useRef<number | null>(null);
  const [nearbyCharacter, setNearbyCharacter] = useState<any>(null);
  const [showDialogue, setShowDialogue] = useState(false);
  const [selectedCharacter, setSelectedCharacter] = useState<any>(null);
  const router = useRouter();

  useEffect(() => {
    if (!mountRef.current) return;

    // Scene setup
    const scene = new THREE.Scene();
    scene.background = new THREE.Color(0xf5f5f5);
    scene.fog = new THREE.Fog(0xf5f5f5, 10, 50);
    sceneRef.current = scene;

    const camera = new THREE.PerspectiveCamera(
      75,
      window.innerWidth / window.innerHeight,
      0.1,
      1000
    );
    camera.position.set(0, 1.6, 5);
    cameraRef.current = camera;

    const renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    rendererRef.current = renderer;
    mountRef.current.appendChild(renderer.domElement);

    // Lighting
    const ambientLight = new THREE.AmbientLight(0xffffff, 0.5);
    scene.add(ambientLight);

    const directionalLight = new THREE.DirectionalLight(0xffffff, 0.5);
    directionalLight.position.set(10, 15, 10);
    directionalLight.castShadow = true;
    directionalLight.shadow.camera.near = 0.1;
    directionalLight.shadow.camera.far = 50;
    directionalLight.shadow.camera.left = -30;
    directionalLight.shadow.camera.right = 30;
    directionalLight.shadow.camera.top = 30;
    directionalLight.shadow.camera.bottom = -30;
    directionalLight.shadow.mapSize.width = 2048;
    directionalLight.shadow.mapSize.height = 2048;
    scene.add(directionalLight);

    // Floor
    const floorGeometry = new THREE.PlaneGeometry(40, 40);
    const floorMaterial = new THREE.MeshStandardMaterial({
      color: 0xdcdcdc,
      roughness: 0.7,
      metalness: 0.1
    });
    const floor = new THREE.Mesh(floorGeometry, floorMaterial);
    floor.rotation.x = -Math.PI / 2;
    floor.receiveShadow = true;
    scene.add(floor);

    // Floor tiles
    const tileGeometry = new THREE.PlaneGeometry(2, 2);
    const tileMaterial1 = new THREE.MeshStandardMaterial({ color: 0xe8e8e8 });
    const tileMaterial2 = new THREE.MeshStandardMaterial({ color: 0xf0f0f0 });

    for (let x = -20; x < 20; x += 2) {
      for (let z = -20; z < 20; z += 2) {
        const tile = new THREE.Mesh(
          tileGeometry,
          ((x + z) / 2) % 2 === 0 ? tileMaterial1 : tileMaterial2
        );
        tile.position.set(x + 1, 0.01, z + 1);
        tile.rotation.x = -Math.PI / 2;
        tile.receiveShadow = true;
        scene.add(tile);
      }
    }

    // Walls
    const wallMaterial = new THREE.MeshStandardMaterial({
      color: 0xf8f8f8,
      roughness: 0.9
    });

    const backWall = new THREE.Mesh(
      new THREE.PlaneGeometry(40, 10),
      wallMaterial
    );
    backWall.position.set(0, 5, -20);
    backWall.receiveShadow = true;
    scene.add(backWall);

    const leftWall = new THREE.Mesh(
      new THREE.PlaneGeometry(40, 10),
      wallMaterial
    );
    leftWall.position.set(-20, 5, 0);
    leftWall.rotation.y = Math.PI / 2;
    leftWall.receiveShadow = true;
    scene.add(leftWall);

    const rightWall = new THREE.Mesh(
      new THREE.PlaneGeometry(40, 10),
      wallMaterial
    );
    rightWall.position.set(20, 5, 0);
    rightWall.rotation.y = -Math.PI / 2;
    rightWall.receiveShadow = true;
    scene.add(rightWall);

    // Create DTalk characters
    const personas = getAllPersonas();
    const characterColors = {
      'steve-jobs': 0x4169e1,
      'aristotle': 0xdaa520,
      'leonardo-da-vinci': 0x8b4513,
      'albert-einstein': 0x9370db,
      'hotaka-funabashi': 0x00ff00,
      'avicii': 0xff1493
    };

    const positions = [
      { x: -10, z: -10 },
      { x: 10, z: -10 },
      { x: -10, z: 0 },
      { x: 10, z: 0 },
      { x: -10, z: 10 },
      { x: 10, z: 10 }
    ];

    function createCharacter(persona: any, position: { x: number; z: number }) {
      const group = new THREE.Group();

      // Body
      const bodyGeometry = new THREE.CylinderGeometry(0.25, 0.3, 0.8, 8);
      const bodyMaterial = new THREE.MeshStandardMaterial({
        color: characterColors[persona.id as keyof typeof characterColors] || 0x808080
      });
      const body = new THREE.Mesh(bodyGeometry, bodyMaterial);
      body.position.y = 0.6;
      body.castShadow = true;
      group.add(body);

      // Head
      const headGeometry = new THREE.SphereGeometry(0.25, 8, 6);
      const headMaterial = new THREE.MeshStandardMaterial({ color: 0xffdbac });
      const head = new THREE.Mesh(headGeometry, headMaterial);
      head.position.y = 1.25;
      head.castShadow = true;
      group.add(head);

      // Name label
      const canvas = document.createElement('canvas');
      canvas.width = 256;
      canvas.height = 64;
      const context = canvas.getContext('2d');
      if (context) {
        context.fillStyle = 'rgba(255, 255, 255, 0.9)';
        context.fillRect(0, 0, 256, 64);
        context.fillStyle = 'black';
        context.font = 'bold 20px Arial';
        context.textAlign = 'center';
        context.fillText(persona.name, 128, 25);
        context.font = '16px Arial';
        context.fillStyle = '#666';
        context.fillText(persona.era, 128, 45);
      }

      const texture = new THREE.CanvasTexture(canvas);
      const labelMaterial = new THREE.SpriteMaterial({ map: texture });
      const label = new THREE.Sprite(labelMaterial);
      label.position.y = 1.8;
      label.scale.set(2, 0.5, 1);
      group.add(label);

      group.position.set(position.x, 0, position.z);
      group.userData = {
        persona,
        initialPosition: new THREE.Vector3(position.x, 0, position.z),
        targetPosition: new THREE.Vector3(position.x, 0, position.z),
        moveTimer: 0
      };

      return group;
    }

    // Add characters to scene
    personas.forEach((persona, index) => {
      if (index < positions.length) {
        const character = createCharacter(persona, positions[index]);
        charactersRef.current.push(character);
        scene.add(character);
      }
    });

    // Event handlers
    const handleKeyDown = (e: KeyboardEvent) => {
      keysRef.current[e.key.toLowerCase()] = true;
      
      if (e.key.toLowerCase() === 'e' && nearbyCharacter && !showDialogue) {
        e.preventDefault();
        setSelectedCharacter(nearbyCharacter);
        setShowDialogue(true);
      }
      
      if (e.key === ' ' && !showDialogue) {
        e.preventDefault();
        playerRef.current.isDancing = true;
      }
      
      if (['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight'].includes(e.key)) {
        e.preventDefault();
      }
    };

    const handleKeyUp = (e: KeyboardEvent) => {
      keysRef.current[e.key.toLowerCase()] = false;
      
      if (e.key === ' ') {
        playerRef.current.isDancing = false;
      }
      
      if (e.key === 'Escape') {
        setShowDialogue(false);
        setSelectedCharacter(null);
        if (document.pointerLockElement === renderer.domElement) {
          document.exitPointerLock();
        }
      }
    };

    const handleMouseMove = (e: MouseEvent) => {
      if (document.pointerLockElement === renderer.domElement && !showDialogue) {
        mouseXRef.current += e.movementX * 0.002;
      }
    };

    const handleClick = () => {
      if (!showDialogue) {
        renderer.domElement.requestPointerLock();
      }
    };

    const handleResize = () => {
      camera.aspect = window.innerWidth / window.innerHeight;
      camera.updateProjectionMatrix();
      renderer.setSize(window.innerWidth, window.innerHeight);
    };

    document.addEventListener('keydown', handleKeyDown);
    document.addEventListener('keyup', handleKeyUp);
    document.addEventListener('mousemove', handleMouseMove);
    renderer.domElement.addEventListener('click', handleClick);
    window.addEventListener('resize', handleResize);

    // Animation loop
    let lastTime = 0;
    const animate = (currentTime: number) => {
      animationIdRef.current = requestAnimationFrame(animate) as number;
      
      const deltaTime = (currentTime - lastTime) / 1000;
      lastTime = currentTime;

      const player = playerRef.current;
      const keys = keysRef.current;
      
      // Player movement
      player.velocity.set(0, 0, 0);
      
      if (!player.isDancing && !showDialogue) {
        if (keys['w']) player.velocity.z = player.speed;
        if (keys['s']) player.velocity.z = -player.speed;
        if (keys['a']) player.velocity.x = -player.speed;
        if (keys['d']) player.velocity.x = player.speed;
      }

      // Camera rotation
      if (!showDialogue) {
        camera.rotation.y = mouseXRef.current;
      }

      // Apply movement
      const forward = new THREE.Vector3(0, 0, -1);
      forward.applyQuaternion(camera.quaternion);
      forward.y = 0;
      forward.normalize();

      const right = new THREE.Vector3(1, 0, 0);
      right.applyQuaternion(camera.quaternion);
      right.y = 0;
      right.normalize();

      player.position.add(forward.multiplyScalar(player.velocity.z));
      player.position.add(right.multiplyScalar(player.velocity.x));

      // Keep player in bounds
      player.position.x = Math.max(-18, Math.min(18, player.position.x));
      player.position.z = Math.max(-18, Math.min(18, player.position.z));

      // Update camera position
      if (player.isDancing) {
        camera.position.y = player.position.y + Math.sin(Date.now() * 0.01) * 0.2;
        camera.rotation.z = Math.sin(Date.now() * 0.01) * 0.1;
      } else {
        camera.position.copy(player.position);
        camera.rotation.z = 0;
      }

      // Update character movement
      charactersRef.current.forEach(character => {
        character.userData.moveTimer -= deltaTime;
        
        if (character.userData.moveTimer <= 0) {
          // Set new random target
          const angle = Math.random() * Math.PI * 2;
          const distance = 3 + Math.random() * 5;
          character.userData.targetPosition = new THREE.Vector3(
            character.userData.initialPosition.x + Math.cos(angle) * distance,
            0,
            character.userData.initialPosition.z + Math.sin(angle) * distance
          );
          
          character.userData.targetPosition.x = Math.max(-18, Math.min(18, character.userData.targetPosition.x));
          character.userData.targetPosition.z = Math.max(-18, Math.min(18, character.userData.targetPosition.z));
          
          character.userData.moveTimer = 5 + Math.random() * 5;
        }
        
        // Move towards target
        const direction = new THREE.Vector3().subVectors(character.userData.targetPosition, character.position);
        direction.y = 0;
        const distance = direction.length();
        
        if (distance > 0.1) {
          direction.normalize();
          character.position.add(direction.multiplyScalar(0.02));
          
          // Face movement direction
          character.lookAt(character.userData.targetPosition);
          character.rotation.x = 0;
          character.rotation.z = 0;
        }
      });

      // Check for nearby characters
      let nearestCharacter = null;
      let minDistance = Infinity;
      
      charactersRef.current.forEach(character => {
        const distance = player.position.distanceTo(character.position);
        if (distance < 3 && distance < minDistance) {
          minDistance = distance;
          nearestCharacter = character;
        }
      });
      
      setNearbyCharacter(nearestCharacter);

      renderer.render(scene, camera);
    };

    animate(0);

    // Cleanup
    return () => {
      if (animationIdRef.current !== null) {
        cancelAnimationFrame(animationIdRef.current);
      }
      document.removeEventListener('keydown', handleKeyDown);
      document.removeEventListener('keyup', handleKeyUp);
      document.removeEventListener('mousemove', handleMouseMove);
      renderer.domElement.removeEventListener('click', handleClick);
      window.removeEventListener('resize', handleResize);
      
      renderer.dispose();
      if (mountRef.current && renderer.domElement) {
        mountRef.current.removeChild(renderer.domElement);
      }
    };
  }, [nearbyCharacter, showDialogue]);

  const handleTalkToCharacter = () => {
    if (selectedCharacter?.userData?.persona) {
      router.push(`/chat/${selectedCharacter.userData.persona.id}`);
    }
  };

  return (
    <div className="relative w-full h-screen">
      <div ref={mountRef} className="w-full h-full" />
      
      {/* UI Overlay */}
      <div className="absolute top-4 left-4 bg-black/70 text-white p-4 rounded-lg backdrop-blur-sm max-w-xs">
        <h2 className="text-xl font-bold mb-2">DTalk 3D探索モード</h2>
        <p className="text-sm mb-1">WASDで移動</p>
        <p className="text-sm mb-1">マウスで視点移動</p>
        <p className="text-sm mb-1">Eキーで対話</p>
        <p className="text-sm mb-1">スペースでダンス</p>
        <p className="text-sm">ESCで終了</p>
      </div>

      {/* Interaction Prompt */}
      {nearbyCharacter && !showDialogue && (
        <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 bg-black/80 text-white px-4 py-2 rounded-full">
          Eキーで{nearbyCharacter.userData.persona.name}と話す
        </div>
      )}

      {/* Dialogue Box */}
      {showDialogue && selectedCharacter && (
        <div className="absolute bottom-4 left-1/2 transform -translate-x-1/2 bg-white/95 p-6 rounded-xl max-w-2xl w-11/12 shadow-2xl backdrop-blur-sm">
          <h3 className="text-xl font-bold text-orange-600 mb-2">
            {selectedCharacter.userData.persona.name} - {selectedCharacter.userData.persona.title}
          </h3>
          <p className="mb-4 text-gray-700">
            {selectedCharacter.userData.persona.name}と対話を始めますか？
          </p>
          <div className="flex gap-4">
            <button
              onClick={handleTalkToCharacter}
              className="bg-orange-600 text-white px-6 py-2 rounded-lg hover:bg-orange-700 transition"
            >
              対話を始める
            </button>
            <button
              onClick={() => setShowDialogue(false)}
              className="bg-gray-300 text-gray-700 px-6 py-2 rounded-lg hover:bg-gray-400 transition"
            >
              キャンセル
            </button>
          </div>
        </div>
      )}
    </div>
  );
}