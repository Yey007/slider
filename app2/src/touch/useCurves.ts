import { useState } from "react";
import { BezierCurve } from "../math/bezier";
import { Point } from "../util/space";

type CurvePointReference = {
  curveIndex: number;
  curvePoint: keyof BezierCurve<"chart">;
};

const DRAG_RADIUS = 20;

export function useCurves(
  initialCurves: BezierCurve<"chart">[],
  toScreenSpace: (point: Point<"chart">) => Point<"screen">,
  toChartSpace: (point: Point<"screen">) => Point<"chart">
) {
  const [curves, setCurves] = useState(initialCurves);
  const [selectedPoint, setSelectedPoint] =
    useState<CurvePointReference | null>(null);

  // TODO: handle empty curves?
  function closestPoint(touchPoint: Point<"screen">) {
    const withDistance: {
      curvePointRef: CurvePointReference;
      distance: number;
    }[] = [];
    for (let i = 0; i < curves.length; i++) {
      const curve = curves[i];
      for (let curvePointType in curve) {
        const asKey = curvePointType as keyof BezierCurve<"chart">;
        const curvePoint = toScreenSpace(curve[asKey]);
        const distance = Math.sqrt(
          (curvePoint.x - touchPoint.x) ** 2 +
            (curvePoint.y - touchPoint.y) ** 2
        );
        withDistance.push({
          curvePointRef: { curveIndex: i, curvePoint: asKey },
          distance,
        });
      }
    }

    const min = withDistance.reduce((min, e) =>
      e.distance < min.distance ? e : min
    );

    return min;
  }

  function tryStartDrag(point: Point<"screen">) {
    const closest = closestPoint(point);
    if (closest.distance > DRAG_RADIUS) {
      return false;
    }

    console.log("Set selected point", closest.curvePointRef);
    setSelectedPoint(closest.curvePointRef);
    return true;
  }

  function continueDrag(touchPoint: Point<"screen">) {
    if (selectedPoint === null) {
      throw new Error("tryStartDrag must succeed before calling continueDrag");
    }

    setCurves((curves) => {
      const newCurves = [...curves];
      const curve = newCurves[selectedPoint.curveIndex];
      newCurves[selectedPoint.curveIndex] = {
        ...curve,
        [selectedPoint.curvePoint]: toChartSpace(touchPoint),
      };
      return newCurves;
    });
  }

  function endDrag() {
    setSelectedPoint(null);
  }

  return {
    curves,
    isDragging: selectedPoint !== null,
    tryStartDrag,
    continueDrag,
    endDrag,
  };
}
