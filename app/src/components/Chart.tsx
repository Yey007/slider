import { useEffect, useRef } from "react";
import { BezierCurve } from "../math/bezier";

import "./Chart.css";
import { useMeasure } from "./useMeasure";

interface ChartProps {
  curves: BezierCurve<"screen">[];
}

interface Dimensions {
  width: number;
  height: number;
}

// https://stackoverflow.com/a/46920541
function fixDpr(ctx: CanvasRenderingContext2D, { width, height }: Dimensions) {
  const dpr = window.devicePixelRatio || 1;
  ctx.canvas.width = width * dpr;
  ctx.canvas.height = height * dpr;
  ctx.canvas.style.width = `${width}px`;
  ctx.canvas.style.height = `${height}px`;
  ctx.scale(dpr, dpr);
}

function clear(ctx: CanvasRenderingContext2D) {
  ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
}

function draw(
  ctx: CanvasRenderingContext2D,
  { width, height }: Dimensions,
  curves: BezierCurve<"screen">[]
) {
  const foreground = getComputedStyle(
    document.documentElement
  ).getPropertyValue("--ion-text-color");

  ctx.strokeStyle = foreground;
  ctx.lineWidth = 1;
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
}

const Chart: React.FC<ChartProps> = ({ curves }) => {
  const canvasRef = useRef<null | HTMLCanvasElement>(null);
  const [ref, dimensions] = useMeasure();

  // Inspiration from https://medium.com/@pdx.lucasm/canvas-with-react-js-32e133c05258
  useEffect(() => {
    const context = canvasRef?.current?.getContext("2d");
    if (!context) return;

    fixDpr(context, dimensions);

    clear(context);
    draw(context, dimensions, curves);
  }, [curves, dimensions.width, dimensions.height]);

  return (
    <div ref={ref} className="container">
      <canvas ref={canvasRef}></canvas>
    </div>
  );
};

export default Chart;
