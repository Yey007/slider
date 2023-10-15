import { canvasDimensions, chartDimensions } from "../main";
import { AffineTransform } from "../math/affine";
import { Matrix2 } from "../math/matrix2";
import { Point } from "../math/space";
import { Vector2 } from "../math/vector2";

export class ViewController {
  private additionalTransform: AffineTransform = AffineTransform.identity();

  startPanZoom(focalPoint: Point<"canvas">) {}

  continuePanZoom(scale: number, focalPoint: Point<"canvas">) {}

  toCanvasSpace(point: Point<"chart">): Point<"canvas"> {
    const vector = new Vector2(point.x, point.y);
    const transform = this.getTransform();
    const result = transform.apply(vector);
    return { x: result.x, y: result.y };
  }

  toChartSpace(point: Point<"canvas">): Point<"chart"> {
    const vector = new Vector2(point.x, point.y);
    const transform = this.getTransform().inverse();
    const result = transform.apply(vector);
    return { x: result.x, y: result.y };
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
