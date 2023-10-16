import { Vector2 } from "./vector2";

export type Space = "canvas" | "chart" | "screen";

export type Dimensions<TSpace extends Space> = {
  width: number;
  height: number;
};

export class Point<TSpace extends Space> {
  constructor(public readonly x: number, public readonly y: number) {}

  public toVector2(): Vector2 {
    return new Vector2(this.x, this.y);
  }

  public distanceTo(point: Point<TSpace>): number {
    return Math.sqrt((this.x - point.x) ** 2 + (this.y - point.y) ** 2);
  }
}
