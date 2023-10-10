import { Point, Space } from "../util/space";

// TODO: make classes, more strictly enforce space stuff?
export type BezierCurve<TSpace extends Space> = {
  start: Point<TSpace>;
  control1: Point<TSpace>;
  control2: Point<TSpace>;
  end: Point<TSpace>;
};
