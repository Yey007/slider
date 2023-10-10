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
      const closest = target.current.closest("ion-content");

      if (closest) {
        gesture = createGesture({
          el: target.current,
          onStart,
          onMove,
          onEnd,
          gestureName: name,
          maxAngle: 180,
        });

        gesture.enable();
      }
    }

    () => gesture?.destroy();
  }, [target]);

  return target;
}
