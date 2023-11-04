import React, { useCallback, useRef } from "react";
import "./Chart.css";
import { Dimensions, Point } from "../util/space";
import { useMeasure } from "../util/useMeasure";
import ChartRender from "./ChartRender";
import { useTransform } from "../math/useCoordinateConverter";
import { BezierCurve } from "../math/bezier";
import { useCurves } from "../touch/useCurves";
import { useGesture } from "../touch/useGesture";
import { useMergedRef } from "../util/useMergedRef";
import { Vector2 } from "../math/vector2";
import { GestureDetail } from "@ionic/react";

const CHART_DIMENSIONS: Dimensions<"chart"> = { width: 1, height: 80 };
const START_CURVES: BezierCurve<"chart">[] = [
  {
    start: { x: 0.1, y: 10 },
    control1: { x: 0.4, y: 10 },
    control2: { x: 0.6, y: 70 },
    end: { x: 0.9, y: 70 },
  },
];

const Chart: React.FC = () => {
  const [ref, canvasDimensions] = useMeasure();

  const { transform, inverse } = useTransform(
    canvasDimensions,
    CHART_DIMENSIONS
  );

  const toScreenSpace = useCallback(
    (point: Point<"chart">): Point<"screen"> => {
      const result = transform.apply(new Vector2(point.x, point.y));
      return { x: result.x, y: result.y };
    },
    [transform]
  );

  const toChartSpace = useCallback(
    (point: Point<"screen">): Point<"chart"> => {
      const result = inverse.apply(new Vector2(point.x, point.y));
      return { x: result.x, y: result.y };
    },
    [inverse]
  );

  const curveToScreenSpace = useCallback(
    (curve: BezierCurve<"chart">): BezierCurve<"screen"> => {
      return {
        start: toScreenSpace(curve.start),
        control1: toScreenSpace(curve.control1),
        control2: toScreenSpace(curve.control2),
        end: toScreenSpace(curve.end),
      };
    },
    [toScreenSpace]
  );

  const { curves, isDragging, tryStartDrag, continueDrag, endDrag } = useCurves(
    START_CURVES,
    toScreenSpace,
    toChartSpace
  );

  const onStart = useCallback(
    (details: GestureDetail) => {
      tryStartDrag({
        x: details.currentX - canvasDimensions.x,
        y: details.currentY - canvasDimensions.y,
      });
    },
    [tryStartDrag, canvasDimensions]
  );

  console.log(isDragging);

  const onMove = useCallback(
    (details: GestureDetail) => {
      console.log(isDragging);
      if (isDragging) {
        continueDrag({
          x: details.currentX - canvasDimensions.x,
          y: details.currentY - canvasDimensions.y,
        });
      }
    },
    [continueDrag, isDragging, canvasDimensions]
  );

  const onEnd = useCallback(() => {
    endDrag();
  }, [endDrag]);

  const gestureTarget = useGesture("pan", onStart, onMove, onEnd);

  const mergedRef = useMergedRef(ref, gestureTarget);

  return (
    <div ref={mergedRef} className="container">
      <ChartRender
        curves={curves.map(curveToScreenSpace)}
        canvasDimensions={canvasDimensions}
      />
    </div>
  );
};

export default Chart;
