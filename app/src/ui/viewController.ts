import { canvasDimensions, chartDimensions } from "../main";
import { AffineTransform } from "../math/affine";
import { BezierCurve } from "../math/bezier";
import { Matrix2 } from "../math/matrix2";
import { Point } from "../math/space";
import { Vector2 } from "../math/vector2";

export class ViewController {
  private additionalTransform: AffineTransform = AffineTransform.identity();

  // TODO: extract delta logic to some other thing?
  private previousScale: number | null = null;
  private previousFocalPoint: Point<"canvas"> | null = null;

  public get isPanZooming(): boolean {
    return this.previousScale !== null && this.previousFocalPoint !== null;
  }

  startPanZoom(focalPoint: Point<"canvas">) {
    if (this.previousScale !== null || this.previousFocalPoint !== null) {
      throw new Error("Cannot start PanZoom without ending it");
    }
    this.previousScale = 1;
    this.previousFocalPoint = focalPoint;
  }

  continuePanZoom(scale: number, focalPoint: Point<"canvas">) {
    if (this.previousScale === null || this.previousFocalPoint === null) {
      throw new Error("Cannot continue PanZoom without starting it");
    }

    var scaleDelta = scale / this.previousScale;
    var pan = focalPoint.toVector2().minus(this.previousFocalPoint.toVector2());

    var panTransform = new AffineTransform(Matrix2.identity(), pan);

    var shiftFocalToOrigin = new AffineTransform(
      Matrix2.identity(),
      focalPoint.toVector2().times(-1)
    );
    var scaleFromOrigin = new AffineTransform(
      new Matrix2(scaleDelta, 0, 0, scaleDelta),
      Vector2.zero()
    );
    var scaleTransform = shiftFocalToOrigin
      .then(scaleFromOrigin)
      .then(shiftFocalToOrigin.inverse());

    this.additionalTransform = this.additionalTransform
      .then(panTransform)
      .then(scaleTransform);

    this.previousScale = scale;
    this.previousFocalPoint = focalPoint;
  }

  endPanZoom() {
    this.previousScale = null;
    this.previousFocalPoint = null;
  }

  toCanvasSpace(point: Point<"chart">): Point<"canvas"> {
    const vector = point.toVector2();
    const transform = this.getTransform();
    const result = transform.apply(vector);
    return result.toPoint();
  }

  toChartSpace(point: Point<"canvas">): Point<"chart"> {
    const vector = point.toVector2();
    const transform = this.getTransform().inverse();
    const result = transform.apply(vector);
    return result.toPoint();
  }

  curveToCanvasSpace(curve: BezierCurve<"chart">): BezierCurve<"canvas"> {
    return {
      start: this.toCanvasSpace(curve.start),
      control1: this.toCanvasSpace(curve.control1),
      control2: this.toCanvasSpace(curve.control2),
      end: this.toCanvasSpace(curve.end),
    };
  }

  curveToChartSpace(curve: BezierCurve<"canvas">): BezierCurve<"chart"> {
    return {
      start: this.toChartSpace(curve.start),
      control1: this.toChartSpace(curve.control1),
      control2: this.toChartSpace(curve.control2),
      end: this.toChartSpace(curve.end),
    };
  }

  private getTransform() {
    const baseTransform = new AffineTransform(
      new Matrix2(
        canvasDimensions.width / chartDimensions.width,
        0,
        0,
        -canvasDimensions.height / chartDimensions.height
      ),
      new Vector2(0, canvasDimensions.height)
    );

    return baseTransform.then(this.additionalTransform);
  }
}
