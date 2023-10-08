export class Vector2 {
  public constructor(public readonly x: number, public readonly y: number) {}

  public static zero(): Vector2 {
    return new Vector2(0, 0);
  }

  public add(vector: Vector2): Vector2 {
    return new Vector2(this.x + vector.x, this.y + vector.y);
  }
}
