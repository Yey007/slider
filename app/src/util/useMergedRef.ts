import { MutableRefObject, RefCallback, useCallback } from "react";

export function useMergedRef(
  ...refs: (
    | RefCallback<HTMLElement | null>
    | MutableRefObject<HTMLElement | null>
  )[]
) {
  return useCallback(
    (element: HTMLElement | null) => {
      for (const ref of refs) {
        if (typeof ref === "function") {
          ref(element);
        } else if (ref) {
          ref.current = element;
        }
      }
    },
    [refs]
  );
}
