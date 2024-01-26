import { Point, Space } from "./space";

export class Vector2 {
  public constructor(public readonly x: number, public readonly y: number) {}

  public static zero(): Vector2 {
    return new Vector2(0, 0);
  }

  public plus(vector: Vector2): Vector2 {
    return new Vector2(this.x + vector.x, this.y + vector.y);
  }

  public minus(vector: Vector2): Vector2 {
    return new Vector2(this.x - vector.x, this.y - vector.y);
  }

  public times(scalar: number): Vector2 {
    return new Vector2(this.x * scalar, this.y * scalar);
  }

  public toPoint<TSpace extends Space>(): Point<TSpace> {
    return new Point(this.x, this.y);
  }
}
