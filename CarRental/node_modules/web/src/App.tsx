import { useEffect, lazy, Suspense } from 'react';
import { Routes, Route } from 'react-router-dom';
import Lenis from 'lenis';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import Home from './pages/Home';

gsap.registerPlugin(ScrollTrigger);

const FleetPage = lazy(() => import('./pages/Fleet'));
const VehicleDetailPage = lazy(() => import('./pages/VehicleDetail'));

const PageLoader = () => (
  <div className="fixed inset-0 bg-[#0D0D0D] flex items-center justify-center z-50">
    <div className="w-12 h-12 rounded-full border-2 border-orange-500/30 border-t-orange-500 animate-spin" />
  </div>
);

function App() {
  useEffect(() => {
    const lenis = new Lenis({
      duration: 1.2,
      easing: (t) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
      orientation: 'vertical',
      gestureOrientation: 'vertical',
      smoothWheel: true,
      wheelMultiplier: 1,
      touchMultiplier: 2,
    });

    lenis.on('scroll', ScrollTrigger.update);

    gsap.ticker.add((time) => {
      lenis.raf(time * 1000);
    });

    gsap.ticker.lagSmoothing(0);

    return () => {
      lenis.destroy();
      gsap.ticker.remove(lenis.raf);
    };
  }, []);

  return (
    <Suspense fallback={<PageLoader />}>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/fleet" element={<FleetPage />} />
        <Route path="/vehicles/:slug" element={<VehicleDetailPage />} />
      </Routes>
    </Suspense>
  );
}

export default App;
