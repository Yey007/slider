import { Point, Space } from "./space";

export class Rect<TSpace extends Space> {
  constructor(
    private readonly topLeft: Point<TSpace>,
    private readonly bottomRight: Point<TSpace>
  ) {}

  get top(): number {
    return this.topLeft.y;
  }

  get bottom(): number {
    return this.bottomRight.y;
  }

  get left(): number {
    return this.topLeft.x;
  }

  get right(): number {
    return this.bottomRight.x;
  }

  get width(): number {
    return Math.abs(this.right - this.left);
  }

  get height(): number {
    return Math.abs(this.bottom - this.top);
  }
}
