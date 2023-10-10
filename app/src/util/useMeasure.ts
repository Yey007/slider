import { MutableRefObject, useLayoutEffect, useRef, useState } from "react";
import { Dimensions, Point } from "./space";

export function useMeasure(): [
  MutableRefObject<HTMLDivElement | null>,
  Dimensions<"screen"> & Point<"screen">
] {
  const ref = useRef<HTMLDivElement | null>(null);
  const [dimensions, setDimensions] = useState({
    width: 0,
    height: 0,
    x: 0,
    y: 0,
  });

  useLayoutEffect(() => {
    const observer = new ResizeObserver((entries) => {
      setDimensions(entries[0].contentRect);
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
