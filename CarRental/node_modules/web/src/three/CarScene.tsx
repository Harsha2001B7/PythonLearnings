// ─────────────────────────────────────────────────────────────────
// CarScene — React Three Fiber canvas scene
// Lazy-loaded from ShowcaseSection via React.lazy + Suspense
// Features:
//   - Orbit controls (limited polar angle)
//   - HDRI environment for realistic reflections
//   - AbstractCar procedural mesh (no IP concerns)
//   - Color prop applied to car body material via ref mutation
//   - CameraRig for animated angle presets
// ─────────────────────────────────────────────────────────────────
import React from 'react';
import { Canvas } from '@react-three/fiber';
import { OrbitControls, Environment, Grid } from '@react-three/drei';
import { AbstractCar } from './AbstractCar';
import { CameraRig } from './CameraRig';

type CameraAngle = 'front' | 'side' | 'rear' | 'top';

interface CarSceneProps {
  color?: string;
  cameraAngle?: CameraAngle;
}

const CarScene: React.FC<CarSceneProps> = ({
  color = '#1a1a1a',
  cameraAngle = 'side',
}) => {
  return (
    <Canvas
      camera={{ position: [5, 1.8, 0], fov: 42 }}
      shadows
      gl={{ antialias: true, alpha: true }}
      style={{ background: 'transparent' }}
      aria-label="Interactive 3D car viewer — drag to rotate"
    >
      {/* ── Lighting ── */}
      {/* Warm key light from front-top */}
      <directionalLight
        position={[5, 8, 5]}
        intensity={1.8}
        castShadow
        shadow-mapSize-width={1024}
        shadow-mapSize-height={1024}
        color="#ffe8cc"
      />
      {/* Cool fill light from rear */}
      <directionalLight position={[-4, 4, -4]} intensity={0.6} color="#cce4ff" />
      {/* Soft ambient */}
      <ambientLight intensity={0.5} color="#f5f0e8" />
      {/* Rim light for vehicle silhouette */}
      <pointLight position={[0, 4, -5]} intensity={0.8} color="#ffffff" />

      {/* ── Environment (HDRI for reflections) ── */}
      <Environment preset="city" />

      {/* ── Ground Grid (subtle) ── */}
      <Grid
        args={[14, 14]}
        position={[0, -0.94, 0]}
        cellSize={0.6}
        cellThickness={0.6}
        cellColor="#e4ded4"
        sectionSize={3}
        sectionThickness={1.2}
        sectionColor="#c8a87a"
        fadeDistance={14}
        fadeStrength={1}
        followCamera={false}
        infiniteGrid={false}
      />

      {/* ── Shadow Catcher Plane ── */}
      <mesh
        rotation={[-Math.PI / 2, 0, 0]}
        position={[0, -0.94, 0]}
        receiveShadow
      >
        <planeGeometry args={[20, 20]} />
        <shadowMaterial opacity={0.12} />
      </mesh>

      {/* ── Car Model ── */}
      <AbstractCar color={color} />

      {/* ── Camera Rig (animated presets) ── */}
      <CameraRig angle={cameraAngle} />

      {/* ── Orbit Controls (user-draggable) ── */}
      <OrbitControls
        enablePan={false}
        enableZoom={true}
        minDistance={3.5}
        maxDistance={10}
        minPolarAngle={Math.PI / 8}      // Don't go below ground
        maxPolarAngle={Math.PI / 2.2}    // Don't flip over top
        target={[0, 0.2, 0]}
        dampingFactor={0.07}
        enableDamping={true}
        rotateSpeed={0.65}
      />
    </Canvas>
  );
};

export default CarScene;
