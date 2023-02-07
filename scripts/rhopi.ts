const LANE_LENGTH = 64;

const stateArrayIndex = (x: number, y: number) => 5 * y + x;

// Convert x and y coordinates of a lane to its initial index in the state array
const calculateLaneOffset = (x: number, y: number) => stateArrayIndex(x, y);

// Calculate the X and Y coordinates of the lanes to update in each round of rho.
const calculateXYPairs = () => {
  let x = 1,
    y = 0;

  const pairs = [];
  for (let t = 0; t < 24; t++) {
    pairs.push([x, y]);
    [x, y] = [y, (2 * x + 3 * y) % 5];
  }

  return pairs;
};


// NOTE: This calculation of the lanes remapping is incorrect.

// Given the x and y coordinates of a lane, return the x and y coordinates of the lane it is mapped to by pi.
const piLaneRemapping = (x: number, y: number): [number, number] => [(x + 3 * y) % 5, x];

console.log('For the rhoPi step, read lanes using the offsets');
console.log(calculateXYPairs().map(([x, y]) => calculateLaneOffset(x, y)));
console.log('then write the values using the offsets');
console.log(calculateXYPairs().map(([x, y]) => calculateLaneOffset(...piLaneRemapping(x, y))));

const modulo = (x: number, n: number): number => ((x % n) + n) % n;

console.log();
console.log('Each lane must be shifted by an amount');
const tArray = Array.from({ length: 24 }, (_, t) => ((t + 1) * (t + 2)) / 2);
console.log(tArray);
console.log('this is equivalent to shifting by');
const moduloTArray = tArray.map((shift) => modulo(shift, LANE_LENGTH));
console.log(moduloTArray);

// console.log(
//   tArray.map((t) => {
//     return Array.from({ length: 64 }, (_, z) => modulo(z - t, 64) - modulo(z - modulo(t, 64), 64));
//   })
// );
