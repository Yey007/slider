import { Vector2 } from "./vector2";

export class Matrix2 {
  public constructor(
    private readonly a00: number,
    private readonly a01: number,
    private readonly a10: number,
    private readonly a11: number
  ) {}

  public static identity(): Matrix2 {
    return new Matrix2(1, 0, 0, 1);
  }

  public multiply(matrix: Matrix2): Matrix2 {
    return new Matrix2(
      this.a00 * matrix.a00 + this.a01 * matrix.a10,
      this.a00 * matrix.a01 + this.a01 * matrix.a11,
      this.a10 * matrix.a00 + this.a11 * matrix.a10,
      this.a10 * matrix.a01 + this.a11 * matrix.a11
    );
  }

  public multiplyVector(vector: Vector2): Vector2 {
    return new Vector2(
      this.a00 * vector.x + this.a01 * vector.y,
      this.a10 * vector.x + this.a11 * vector.y
    );
  }

  public scale(scale: number): Matrix2 {
    return new Matrix2(
      this.a00 * scale,
      this.a01 * scale,
      this.a10 * scale,
      this.a11 * scale
    );
  }

  public inverse(): Matrix2 {
    const det = this.a00 * this.a11 - this.a01 * this.a10;
    return new Matrix2(
      this.a11 / det,
      -this.a01 / det,
      -this.a10 / det,
      this.a00 / det
    );
  }
}
