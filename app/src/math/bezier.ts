type Space = "screen" | "chart";

export type Point<TSpace extends Space> = {
  x: number;
  y: number;
};

export type BezierCurve<TSpace extends Space> = {
  start: Point<TSpace>;
  control1: Point<TSpace>;
  control2: Point<TSpace>;
  end: Point<TSpace>;
};
