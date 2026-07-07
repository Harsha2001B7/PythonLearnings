// ─────────────────────────────────────────────────────────────────
// AbstractCar — Procedural 3D car built from R3F primitives
// Used as a fallback if a real GLB model fails to load.
// Design: clean, wireframe-edged, stylized — art over realism.
// ─────────────────────────────────────────────────────────────────
import React, { useRef } from 'react';
import { useFrame } from '@react-three/fiber';
import * as THREE from 'three';

interface AbstractCarProps {
  color?: string;
}

export const AbstractCar: React.FC<AbstractCarProps> = ({ color = '#1a1a1a' }) => {
  const groupRef = useRef<THREE.Group>(null!);

  // Gentle idle rotation
  useFrame((_, delta) => {
    if (groupRef.current) {
      groupRef.current.rotation.y += delta * 0.18;
    }
  });

  const bodyMat = { color, roughness: 0.15, metalness: 0.8 };
  const glassMat = { color: '#88aacc', roughness: 0.05, metalness: 0.1, transparent: true, opacity: 0.55 };
  const chromeMat = { color: '#cccccc', roughness: 0.05, metalness: 1.0 };
  const tireMat = { color: '#111111', roughness: 0.9, metalness: 0.0 };
  const rimMat = { color: '#888888', roughness: 0.1, metalness: 0.9 };

  return (
    <group ref={groupRef} position={[0, -0.5, 0]} scale={1.1}>
      {/* ── Main Body ── */}
      <mesh position={[0, 0.35, 0]} castShadow>
        <boxGeometry args={[3.6, 0.6, 1.65]} />
        <meshStandardMaterial {...bodyMat} />
      </mesh>

      {/* ── Cabin / Greenhouse ── */}
      <mesh position={[0.1, 0.9, 0]} castShadow>
        <boxGeometry args={[1.9, 0.55, 1.45]} />
        <meshStandardMaterial {...bodyMat} />
      </mesh>

      {/* ── Windshield ── */}
      <mesh position={[0.97, 0.82, 0]} rotation={[0, 0, -0.38]}>
        <boxGeometry args={[0.04, 0.54, 1.3]} />
        <meshStandardMaterial {...glassMat} />
      </mesh>

      {/* ── Rear Window ── */}
      <mesh position={[-0.83, 0.82, 0]} rotation={[0, 0, 0.38]}>
        <boxGeometry args={[0.04, 0.54, 1.3]} />
        <meshStandardMaterial {...glassMat} />
      </mesh>

      {/* ── Side Windows ── */}
      <mesh position={[0.1, 0.9, 0.73]}>
        <boxGeometry args={[1.7, 0.42, 0.04]} />
        <meshStandardMaterial {...glassMat} />
      </mesh>
      <mesh position={[0.1, 0.9, -0.73]}>
        <boxGeometry args={[1.7, 0.42, 0.04]} />
        <meshStandardMaterial {...glassMat} />
      </mesh>

      {/* ── Front Hood ── */}
      <mesh position={[1.55, 0.38, 0]} castShadow>
        <boxGeometry args={[0.6, 0.08, 1.55]} />
        <meshStandardMaterial {...bodyMat} />
      </mesh>

      {/* ── Rear Trunk ── */}
      <mesh position={[-1.45, 0.38, 0]} castShadow>
        <boxGeometry args={[0.7, 0.08, 1.55]} />
        <meshStandardMaterial {...bodyMat} />
      </mesh>

      {/* ── Front Bumper ── */}
      <mesh position={[1.88, 0.2, 0]}>
        <boxGeometry args={[0.12, 0.28, 1.62]} />
        <meshStandardMaterial {...bodyMat} />
      </mesh>

      {/* ── Rear Bumper ── */}
      <mesh position={[-1.88, 0.2, 0]}>
        <boxGeometry args={[0.12, 0.28, 1.62]} />
        <meshStandardMaterial {...bodyMat} />
      </mesh>

      {/* ── Headlights ── */}
      <mesh position={[1.9, 0.33, 0.58]}>
        <boxGeometry args={[0.06, 0.12, 0.38]} />
        <meshStandardMaterial color="#ffffee" emissive="#ffcc44" emissiveIntensity={0.5} roughness={0.1} />
      </mesh>
      <mesh position={[1.9, 0.33, -0.58]}>
        <boxGeometry args={[0.06, 0.12, 0.38]} />
        <meshStandardMaterial color="#ffffee" emissive="#ffcc44" emissiveIntensity={0.5} roughness={0.1} />
      </mesh>

      {/* ── Taillights ── */}
      <mesh position={[-1.9, 0.33, 0.58]}>
        <boxGeometry args={[0.06, 0.12, 0.38]} />
        <meshStandardMaterial color="#ff2200" emissive="#ff2200" emissiveIntensity={0.8} roughness={0.1} />
      </mesh>
      <mesh position={[-1.9, 0.33, -0.58]}>
        <boxGeometry args={[0.06, 0.12, 0.38]} />
        <meshStandardMaterial color="#ff2200" emissive="#ff2200" emissiveIntensity={0.8} roughness={0.1} />
      </mesh>

      {/* ── Chrome Grille ── */}
      <mesh position={[1.9, 0.25, 0]}>
        <boxGeometry args={[0.04, 0.18, 1.0]} />
        <meshStandardMaterial {...chromeMat} />
      </mesh>

      {/* ── Wheels (4x) ── */}
      {(
        [
          [1.1, -0.1, 0.92],
          [1.1, -0.1, -0.92],
          [-1.0, -0.1, 0.92],
          [-1.0, -0.1, -0.92],
        ] as [number, number, number][]
      ).map((pos, i) => (
        <group key={i} position={pos} rotation={[Math.PI / 2, 0, 0]}>
          {/* Tyre */}
          <mesh castShadow>
            <cylinderGeometry args={[0.35, 0.35, 0.22, 28]} />
            <meshStandardMaterial {...tireMat} />
          </mesh>
          {/* Rim */}
          <mesh>
            <cylinderGeometry args={[0.22, 0.22, 0.24, 20]} />
            <meshStandardMaterial {...rimMat} />
          </mesh>
          {/* Hub */}
          <mesh>
            <cylinderGeometry args={[0.06, 0.06, 0.26, 8]} />
            <meshStandardMaterial color="#444" metalness={0.9} roughness={0.2} />
          </mesh>
        </group>
      ))}

      {/* ── Ground Shadow (soft disc) ── */}
      <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, -0.44, 0]} receiveShadow scale={[2.4, 1.1, 1]}>
        <circleGeometry args={[1, 32]} />
        <meshStandardMaterial color="#000" transparent opacity={0.08} />
      </mesh>
    </group>
  );
};

export default AbstractCar;
