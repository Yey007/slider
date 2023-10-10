import React, { useRef } from "react";
import "./Chart.css";
import { Dimensions } from "../util/space";
import { useMeasure } from "../util/useMeasure";
import ChartRender from "./ChartRender";
import { useCoordinateConverter } from "../math/useCoordinateConverter";
import { BezierCurve } from "../math/bezier";
import { useCurves } from "../touch/useCurves";
import { useGesture } from "../touch/useGesture";
import { useMergedRef } from "../util/useMergedRef";
import { AffineTransform } from "../math/affine";
import { Matrix2 } from "../math/matrix2";
import { Vector2 } from "../math/vector2";

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

  const { toScreenSpace, toChartSpace } = useCoordinateConverter(
    canvasDimensions,
    CHART_DIMENSIONS
  );

  function curveToScreenSpace(curve: BezierCurve<"chart">) {
    return {
      start: toScreenSpace(curve.start),
      control1: toScreenSpace(curve.control1),
      control2: toScreenSpace(curve.control2),
      end: toScreenSpace(curve.end),
    };
  }

  const { curves, isDragging, tryStartDrag, continueDrag, endDrag } = useCurves(
    START_CURVES,
    toScreenSpace,
    toChartSpace
  );

  const gestureTarget = useGesture(
    "pan",
    (details) => {
      tryStartDrag({
        x: details.currentX - canvasDimensions.x,
        y: details.currentY - canvasDimensions.y,
      });
    },
    (details) => {
      if (isDragging) {
        continueDrag({
          x: details.currentX - canvasDimensions.x,
          y: details.currentY - canvasDimensions.y,
        });
      }
    },
    () => {
      endDrag();
    }
  );

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
