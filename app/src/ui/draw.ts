import { canvasDimensions } from "../main";
import { BezierCurve } from "../math/bezier";
import { Point } from "../math/space";

export function fixDpr(ctx: CanvasRenderingContext2D) {
  const { width, height } = canvasDimensions;
  const dpr = window.devicePixelRatio || 1;

  ctx.canvas.width = width * dpr;
  ctx.canvas.height = height * dpr;
  ctx.canvas.style.width = `${width}px`;
  ctx.canvas.style.height = `${height}px`;
  ctx.scale(dpr, dpr);
}

export function clear(ctx: CanvasRenderingContext2D) {
  ctx.reset();
}

const CONTROL_RADIUS = 8;

// TODO: don' draw curves into points
export function draw(
  ctx: CanvasRenderingContext2D,
  curves: BezierCurve<"canvas">[]
) {
  const { width, height } = canvasDimensions;
  const foreground = "#ffffff";

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

  function line(start: Point<"canvas">, end: Point<"canvas">) {
    ctx.beginPath();
    ctx.moveTo(start.x, start.y);
    ctx.lineTo(end.x, end.y);
    ctx.stroke();
  }

  function circle(point: Point<"canvas">, radius: number) {
    ctx.beginPath();
    ctx.arc(point.x, point.y, radius, 0, 2 * Math.PI);
    ctx.stroke();
  }

  function drawPoint(point: Point<"canvas">) {
    circle(point, CONTROL_RADIUS);
  }

  function drawControlPoint(
    controlPoint: Point<"canvas">,
    relatedEndpoint: Point<"canvas">
  ) {
    const r = CONTROL_RADIUS;
    circle(controlPoint, r);

    const k =
      Math.pow(controlPoint.x - relatedEndpoint.x, 2) +
      Math.pow(controlPoint.y - relatedEndpoint.y, 2);

    const t0 = (2 * k + Math.sqrt(4 * k * k - 4 * k * (k - r * r))) / (2 * k);
    const t1 = (2 * k - Math.sqrt(4 * k * k - 4 * k * (k - r * r))) / (2 * k);

    let t: number;
    if (t0 < 1) {
      t = t0;
    } else if (t1 < 1) {
      t = t1;
    } else {
      return;
    }

    const x = (controlPoint.x - relatedEndpoint.x) * t + relatedEndpoint.x;
    const y = (controlPoint.y - relatedEndpoint.y) * t + relatedEndpoint.y;

    line(relatedEndpoint, { x, y });
  }

  function drawCurve(curve: BezierCurve<"canvas">) {
    ctx.beginPath();
    ctx.moveTo(curve.start.x, curve.start.y);
    ctx.bezierCurveTo(
      curve.control1.x,
      curve.control1.y,
      curve.control2.x,
      curve.control2.y,
      curve.end.x,
      curve.end.y
    );
    ctx.stroke();
  }

  for (const curve of curves) {
    drawCurve(curve);
    drawPoint(curve.start);
    drawPoint(curve.end);
    drawControlPoint(curve.control1, curve.start);
    drawControlPoint(curve.control2, curve.end);
  }
}
