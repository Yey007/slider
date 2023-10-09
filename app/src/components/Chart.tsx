import { useEffect, useRef } from "react";

import "./Chart.css";
import { useMeasure } from "../util/useMeasure";
import { useCoordinateConverter } from "../math/useCoordinateConverter";
import { BezierCurve } from "../math/objects";
import { Dimensions } from "../util/space";

interface ChartProps {
  curves: BezierCurve<"screen">[];
}

// https://stackoverflow.com/a/46920541
function fixDpr(
  ctx: CanvasRenderingContext2D,
  { width, height }: Dimensions<"screen">
) {
  const dpr = window.devicePixelRatio || 1;
  ctx.canvas.width = width * dpr;
  ctx.canvas.height = height * dpr;
  ctx.canvas.style.width = `${width}px`;
  ctx.canvas.style.height = `${height}px`;
  ctx.scale(dpr, dpr);
}

function clear(ctx: CanvasRenderingContext2D) {
  ctx.reset();
}

function draw(
  ctx: CanvasRenderingContext2D,
  { width, height }: Dimensions<"screen">,
  curves: BezierCurve<"screen">[]
) {
  const foreground = getComputedStyle(
    document.documentElement
  ).getPropertyValue("--ion-text-color");

  ctx.strokeStyle = foreground;
  ctx.lineWidth = 2;
  ctx.lineCap = "round";

  // Prevent stuff clipping on the edges
  const inset = 1;
  ctx.transform(
    (width - 2 * inset) / width,
    0,
    0,
    (height - 2 * inset) / height,
    inset,
    inset
  );

  ctx.beginPath();
  ctx.moveTo(0, 0);
  ctx.lineTo(0, height);
  ctx.lineTo(width, height);
  ctx.stroke();

  ctx.arc(0, height, 10, 0, 2 * Math.PI);
  ctx.stroke();
}

const Chart: React.FC<ChartProps> = ({ curves }) => {
  const canvasRef = useRef<null | HTMLCanvasElement>(null);
  const [ref, dimensions] = useMeasure();
  const { toScreenSpace, toChartSpace, panZoom } =
    useCoordinateConverter(dimensions);

  // Inspiration from https://medium.com/@pdx.lucasm/canvas-with-react-js-32e133c05258
  useEffect(() => {
    const context = canvasRef?.current?.getContext("2d");
    if (!context) return;

    clear(context);
    fixDpr(context, dimensions);
    draw(context, dimensions, curves);
  }, [curves, dimensions.width, dimensions.height]);

  return (
    <div ref={ref} className="container">
      <canvas ref={canvasRef}></canvas>
    </div>
  );
};

export default Chart;
