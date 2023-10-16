import { canvasDimensions, chartDimensions } from "../main";
import { AffineTransform } from "../math/affine";
import { BezierCurve } from "../math/bezier";
import { Matrix2 } from "../math/matrix2";
import { Point } from "../math/space";
import { Vector2 } from "../math/vector2";

export class ViewController {
  private additionalTransform: AffineTransform = AffineTransform.identity();

  startPanZoom(focalPoint: Point<"canvas">) {}

  continuePanZoom(scale: number, focalPoint: Point<"canvas">) {}

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
