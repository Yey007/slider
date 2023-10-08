import { LegacyRef, useLayoutEffect, useRef, useState } from "react";

export function useMeasure(): [
  LegacyRef<HTMLDivElement>,
  { width: number; height: number }
] {
  const ref = useRef<HTMLDivElement | null>(null);
  const [dimensions, setDimensions] = useState({ width: 0, height: 0 });

  useLayoutEffect(() => {
    const observer = new ResizeObserver((entries) => {
      const { width, height } = entries[0].contentRect;
      setDimensions({ width, height });
    });

    if (ref.current) {
      observer.observe(ref.current);
    }

    return () => {
      observer.disconnect();
    };
  }, []);

  return [ref, dimensions];
}
