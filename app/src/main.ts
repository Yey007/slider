import { BezierCurve } from "./math/bezier";
import { Dimensions } from "./math/space";
import { clear, draw, fixDpr } from "./ui/draw";
import { ViewController as ViewController } from "./ui/viewController";

const CHART_DIMENSIONS: Dimensions<"chart"> = { width: 1, height: 80 };
const START_CURVES: BezierCurve<"chart">[] = [
  {
    start: { x: 0.1, y: 10 },
    control1: { x: 0.4, y: 10 },
    control2: { x: 0.6, y: 70 },
    end: { x: 0.9, y: 70 },
  },
];

const view = new ViewController();

const container = document.querySelector(".child-container")!;
const canvas = document.querySelector("canvas")!;

export let chartDimensions = CHART_DIMENSIONS;
export let canvasDimensions = { width: 0, height: 0 };

function update() {
  const context = canvas.getContext("2d")!;
  canvasDimensions = container.getBoundingClientRect();

  function curveToCanvasSpace(
    curve: BezierCurve<"chart">
  ): BezierCurve<"canvas"> {
    return {
      start: view.toCanvasSpace(curve.start),
      control1: view.toCanvasSpace(curve.control1),
      control2: view.toCanvasSpace(curve.control2),
      end: view.toCanvasSpace(curve.end),
    };
  }

  clear(context);
  fixDpr(context);
  draw(context, START_CURVES.map(curveToCanvasSpace));

  window.requestAnimationFrame(update);
}

window.requestAnimationFrame(update);
