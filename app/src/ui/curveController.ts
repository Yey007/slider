import { BezierCurve } from "../math/bezier";
import { Point } from "../math/space";
import { ViewController } from "./viewController";

const DRAG_RADIUS = 10;

type CurvePointReference = [number, keyof BezierCurve<"chart">];

export class CurveController {
  private selectedCurvePoint: CurvePointReference | null = null;

  constructor(
    private view: ViewController,
    public curves: BezierCurve<"chart">[]
  ) {}

  public get isDragging(): boolean {
    return this.selectedCurvePoint !== null;
  }

  public tryStartDrag(point: Point<"canvas">): boolean {
    const chartSpace = this.view.toChartSpace(point);
    const [closestIndex, closestType] = this.closestCurvePoint(chartSpace);
    const closestCanvasSpace = this.view.toCanvasSpace(
      this.curves[closestIndex][closestType]
    );

    const canvasDistance = closestCanvasSpace.distanceTo(point);
    if (canvasDistance > DRAG_RADIUS) {
      return false;
    }

    this.selectedCurvePoint = [closestIndex, closestType];
    return true;
  }

  public continueDrag(point: Point<"canvas">): void {
    if (!this.selectedCurvePoint) {
      throw new Error("Cannot continue drag without starting it");
    }

    const chartSpace = this.view.toChartSpace(point);
    const [index, type] = this.selectedCurvePoint;
    this.curves[index][type] = chartSpace;
  }

  public endDrag(): void {
    this.selectedCurvePoint = null;
  }

  private closestCurvePoint(point: Point<"chart">): CurvePointReference {
    const refs = this.curves.flatMap((_, i) => {
      return [
        [i, "start"] as CurvePointReference,
        [i, "control1"] as CurvePointReference,
        [i, "control2"] as CurvePointReference,
        [i, "end"] as CurvePointReference,
      ];
    });

    const distances = refs.map((ref) => {
      const [curveIndex, pointKey] = ref;
      const curve = this.curves[curveIndex];
      const curvePoint = curve[pointKey];
      return {
        ref,
        dist: curvePoint.distanceTo(point),
      };
    });

    return distances.reduce((prev, curr) => {
      return prev.dist < curr.dist ? prev : curr;
    }).ref;
  }
}
