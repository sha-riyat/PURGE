"use client";

import { useEffect } from "react";
import { animate, inView } from "motion";

export function MotionScroll() {
  useEffect(() => {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;

    const sections = Array.from(document.querySelectorAll<HTMLElement>("#top > section"));
    const seen = new WeakSet<HTMLElement>();
    const cleanups = sections.map((section, index) => {
      section.style.opacity = "0";
      section.style.transform = "translateY(24px)";

      return inView(
        section,
        () => {
          if (seen.has(section)) return;
          seen.add(section);

          const controls = animate(
            section,
            { opacity: 1, y: 0 },
            { duration: 0.65, delay: Math.min(index * 0.04, 0.16), ease: [0.22, 1, 0.36, 1] },
          );

          return () => controls.stop();
        },
        { amount: 0.14 },
      );
    });

    return () => cleanups.forEach((cleanup) => cleanup());
  }, []);

  return null;
}
