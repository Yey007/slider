import { Point, Space } from "./space";

// TODO: make classes, more strictly enforce space stuff?
// TODO: immutable?
export type BezierCurve<TSpace extends Space> = {
  start: Point<TSpace>;
  control1: Point<TSpace>;
  control2: Point<TSpace>;
  end: Point<TSpace>;
};
