import { Gesture, GestureDetail, createGesture } from "@ionic/react";
import { useEffect, useRef } from "react";

export function useGesture(
  name: string,
  onStart: (detail: GestureDetail) => void,
  onMove: (detail: GestureDetail) => void,
  onEnd: (detail: GestureDetail) => void
) {
  const target = useRef<HTMLElement | null>(null);

  useEffect(() => {
    let gesture: Gesture | undefined;
    if (target.current) {
      console.log("create gesture");
      gesture = createGesture({
        el: target.current,
        gestureName: name,
        onStart,
        onMove,
        onEnd,
        maxAngle: 180,
      });

      gesture.enable();
    }

    () => {
      console.log("destroy gesture");
      gesture?.destroy();
    };
  }, [target.current, onStart, onMove, onEnd, name]);

  return target;
}
