import { BezierCurve } from "./math/bezier";
import { Dimensions, Point } from "./math/space";
import { CurveController } from "./ui/curveController";
import { clear, draw, fixDpr } from "./ui/draw";
import { ViewController as ViewController } from "./ui/viewController";
import Hammer from "hammerjs";

const container = document.querySelector(".child-container")!;
const canvas = document.querySelector("canvas")!;

const hammertime = new Hammer(canvas);

const CHART_DIMENSIONS: Dimensions<"chart"> = { width: 1, height: 80 };
const START_CURVES: BezierCurve<"chart">[] = [
  {
    start: new Point(0.1, 10),
    control1: new Point(0.4, 10),
    control2: new Point(0.6, 70),
    end: new Point(0.9, 70),
  },
];

const view = new ViewController();
const curveController = new CurveController(view, START_CURVES);

function screenToCanvasCoordinates(point: Point<"screen">): Point<"canvas"> {
  const boundingRect = canvas.getBoundingClientRect();
  return new Point(point.x - boundingRect.x, point.y - boundingRect.y);
}

// TODO: extract
hammertime.get("pan").set({ direction: Hammer.DIRECTION_ALL, threshold: 0 });
hammertime
  .get("pinch")
  .set({ enable: true, direction: Hammer.DIRECTION_ALL, threshold: 0 });

hammertime.on("panstart", (e) => {
  const point = screenToCanvasCoordinates(new Point(e.center.x, e.center.y));
  const result = curveController.tryStartDrag(point);
  if (!result) {
    view.startPanZoom(point);
  }
});

hammertime.on("panmove", (e) => {
  const point = screenToCanvasCoordinates(new Point(e.center.x, e.center.y));
  if (curveController.isDragging) {
    curveController.continueDrag(point);
  } else {
    view.continuePanZoom(e.scale, point);
  }
});

hammertime.on("panend", () => {
  if (view.isPanZooming) {
    view.endPanZoom();
  }

  if (curveController.isDragging) {
    curveController.endDrag();
  }
});

hammertime.on("pinchstart", (e) => {
  const point = screenToCanvasCoordinates(new Point(e.center.x, e.center.y));
  view.startPanZoom(point);
});

hammertime.on("pinchmove", (e) => {
  const point = screenToCanvasCoordinates(new Point(e.center.x, e.center.y));
  view.continuePanZoom(e.scale, point);
});

hammertime.on("pinchend", () => {
  view.endPanZoom();
});

const SCALE_FACTOR = 1000;
let timeout: number | null = null;
let scaleSum = 0;

canvas.addEventListener("wheel", (ev) => {
  const position = screenToCanvasCoordinates(new Point(ev.x, ev.y));
  scaleSum += ev.deltaY;
  const scale = Math.exp(-scaleSum / SCALE_FACTOR);

  if (!view.isPanZooming) {
    view.startPanZoom(position);
  } else {
    view.continuePanZoom(scale, position);
  }

  if (timeout) {
    window.clearTimeout(timeout);
    timeout = null;
  }

  timeout = window.setTimeout(() => {
    scaleSum = 0;
    view.endPanZoom();
  }, 100);
});

export let chartDimensions = CHART_DIMENSIONS;
export let canvasDimensions = { width: 0, height: 0 };

function update() {
  const context = canvas.getContext("2d")!;
  canvasDimensions = container.getBoundingClientRect();

  clear(context);
  fixDpr(context);
  draw(
    context,
    START_CURVES.map((c) => view.curveToCanvasSpace(c))
  );

  window.requestAnimationFrame(update);
}

window.requestAnimationFrame(update);
