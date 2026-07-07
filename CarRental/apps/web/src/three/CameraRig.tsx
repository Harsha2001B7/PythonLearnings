// ─────────────────────────────────────────────────────────────────
// CameraRig — Animates camera to preset angles on command
// Uses useFrame for smooth lerping to target positions
// ─────────────────────────────────────────────────────────────────
import { useRef, useEffect } from 'react';
import { useFrame, useThree } from '@react-three/fiber';
import * as THREE from 'three';

type CameraAngle = 'front' | 'side' | 'rear' | 'top';

const CAMERA_POSITIONS: Record<CameraAngle, THREE.Vector3> = {
  side:  new THREE.Vector3(5, 1.8, 0),
  front: new THREE.Vector3(0, 1.5, 6),
  rear:  new THREE.Vector3(0, 1.5, -6),
  top:   new THREE.Vector3(0, 6.5, 1),
};

interface CameraRigProps {
  angle: CameraAngle;
}

export const CameraRig: React.FC<CameraRigProps> = ({ angle }) => {
  const { camera } = useThree();
  const targetPosition = useRef(CAMERA_POSITIONS[angle].clone());
  const lookAtTarget = useRef(new THREE.Vector3(0, 0.3, 0));

  useEffect(() => {
    targetPosition.current.copy(CAMERA_POSITIONS[angle]);
  }, [angle]);

  useFrame(() => {
    camera.position.lerp(targetPosition.current, 0.05);
    camera.lookAt(lookAtTarget.current);
  });

  return null;
};

export default CameraRig;
