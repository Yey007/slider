export type Space = "canvas" | "chart";

export type Dimensions<TSpace extends Space> = {
  width: number;
  height: number;
};

export type Point<TSpace extends Space> = {
  x: number;
  y: number;
};
