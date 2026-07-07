import { useEffect } from 'react';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

export const useGSAPReveal = () => {
  useEffect(() => {
    // Staggered Text Reveal
    const textReveals = document.querySelectorAll('.gsap-reveal-text');
    textReveals.forEach((element) => {
      gsap.fromTo(
        element,
        { opacity: 0, y: 50 },
        {
          opacity: 1,
          y: 0,
          duration: 1.2,
          ease: 'power3.out',
          scrollTrigger: {
            trigger: element,
            start: 'top 85%',
            toggleActions: 'play none none reverse',
          },
        }
      );
    });

    // Image Parallax Reveal
    const imageReveals = document.querySelectorAll('.gsap-reveal-image');
    imageReveals.forEach((element) => {
      gsap.fromTo(
        element,
        { scale: 1.1, opacity: 0, clipPath: 'inset(10% 0% 10% 0%)' },
        {
          scale: 1,
          opacity: 1,
          clipPath: 'inset(0% 0% 0% 0%)',
          duration: 1.5,
          ease: 'power4.out',
          scrollTrigger: {
            trigger: element,
            start: 'top 90%',
            toggleActions: 'play none none reverse',
          },
        }
      );
    });

    // Staggered Cards Reveal
    const staggerContainers = document.querySelectorAll('.gsap-stagger-container');
    staggerContainers.forEach((container) => {
      const items = container.querySelectorAll('.gsap-stagger-item');
      gsap.fromTo(
        items,
        { opacity: 0, y: 40 },
        {
          opacity: 1,
          y: 0,
          duration: 1,
          stagger: 0.1,
          ease: 'power3.out',
          scrollTrigger: {
            trigger: container,
            start: 'top 85%',
            toggleActions: 'play none none reverse',
          },
        }
      );
    });

    return () => {
      ScrollTrigger.getAll().forEach((trigger) => trigger.kill());
    };
  }, []);
};
