import { Matrix2 } from "./matrix2";
import { Vector2 } from "./vector2";

export class AffineTransform {
  public constructor(
    public readonly matrix: Matrix2,
    public readonly constant: Vector2
  ) {}

  public static identity(): AffineTransform {
    return new AffineTransform(Matrix2.identity(), Vector2.zero());
  }

  public apply(vector: Vector2): Vector2 {
    return this.matrix.multiplyVector(vector).add(this.constant);
  }

  public compose(other: AffineTransform): AffineTransform {
    return new AffineTransform(
      this.matrix.multiply(other.matrix),
      this.apply(other.constant)
    );
  }

  public then(other: AffineTransform): AffineTransform {
    return other.compose(this);
  }

  public inverse(): AffineTransform {
    const inverse = this.matrix.inverse();
    return new AffineTransform(
      inverse,
      inverse.scale(-1).multiplyVector(this.constant)
    );
  }
}
