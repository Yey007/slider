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

hammertime.get("pan").set({ direction: Hammer.DIRECTION_ALL, threshold: 0 });

hammertime.on("panstart", (e) => {
  const point = screenToCanvasCoordinates(new Point(e.center.x, e.center.y));
  curveController.tryStartDrag(point);
});

hammertime.on("panmove", (e) => {
  const point = screenToCanvasCoordinates(new Point(e.center.x, e.center.y));
  if (!curveController.isDragging) {
    return;
  }
  curveController.continueDrag(point);
});

hammertime.on("panend", () => {
  curveController.endDrag();
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
