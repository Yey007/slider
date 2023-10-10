import { useState } from "react";
import { AffineTransform } from "./affine";
import { Matrix2 } from "./matrix2";
import { Dimensions, Point } from "../util/space";
import { Vector2 } from "./vector2";

export function useCoordinateConverter(
  canvasDimensions: Dimensions<"screen">,
  chartDimensions: Dimensions<"chart">
) {
  const baseTransform = new AffineTransform(
    new Matrix2(
      canvasDimensions.width / chartDimensions.width,
      0,
      0,
      -canvasDimensions.height / chartDimensions.height
    ),
    new Vector2(0, canvasDimensions.height)
  );

  const [additionalTransform, setAdditionalTransform] = useState(
    AffineTransform.identity()
  );

  const transform = baseTransform.then(additionalTransform);
  const inverse = transform.inverse();

  function toScreenSpace(point: Point<"chart">): Point<"screen"> {
    const result = transform.apply(new Vector2(point.x, point.y));
    return { x: result.x, y: result.y };
  }

  function toChartSpace(point: Point<"screen">): Point<"chart"> {
    const result = inverse.apply(new Vector2(point.x, point.y));
    return { x: result.x, y: result.y };
  }

  function startPanZoom(focalPoint: Point<"screen">) {}

  function panZoom(scale: number, focalPoint: Point<"screen">) {}

  return {
    toScreenSpace,
    toChartSpace,
    startPanZoom,
    panZoom,
  };
}
