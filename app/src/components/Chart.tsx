import React from "react";
import "./Chart.css";
import { Dimensions } from "../util/space";
import { useMeasure } from "../util/useMeasure";
import ChartRender from "./ChartRender";
import { useCoordinateConverter } from "../math/useCoordinateConverter";
import { BezierCurve } from "../math/bezier";

const CHART_DIMENSIONS: Dimensions<"chart"> = { width: 1, height: 80 };
const CURVES: BezierCurve<"chart">[] = [
  {
    start: { x: 0.1, y: 10 },
    control1: { x: 0.4, y: 10 },
    control2: { x: 0.6, y: 70 },
    end: { x: 0.9, y: 70 },
  },
];

const Chart: React.FC = () => {
  const [ref, canvasDimensions] = useMeasure();

  const { toScreenSpace, toChartSpace, panZoom } = useCoordinateConverter(
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

  return (
    <div ref={ref} className="container">
      <ChartRender
        curves={CURVES.map(curveToScreenSpace)}
        canvasDimensions={canvasDimensions}
      />
    </div>
  );
};

export default Chart;
