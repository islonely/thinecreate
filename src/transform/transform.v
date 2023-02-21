module transform

import math

// Rotation is the orientation of an object.
pub struct Rotation {
__global:
	pitch f32
	yaw   f32
	roll  f32
}

// Vector3
pub struct Vector3 {
__global:
	x f32
	y f32
	z f32
}

// + adds the two Vector3's together.
pub fn (a Vector3) + (b Vector3) Vector3 {
	return Vector3{
		x: a.x + b.x
		y: a.y + b.y
		z: a.z + b.z
	}
}

// + adds the two Vector3's together.
pub fn (a Vector3) - (b Vector3) Vector3 {
	return Vector3{
		x: a.x - b.x
		y: a.y - b.y
		z: a.z - b.z
	}
}

// * multiplies two Vector3's together.
pub fn (a Vector3) * (b Vector3) Vector3 {
	return Vector3{
		x: a.x * b.x
		y: a.y * b.y
		z: a.z * b.z
	}
}

// multf32 multiplies X, Y, and Z by one value.
pub fn (a Vector3) multf32(val f32) Vector3 {
	return a * Vector3{val, val, val}
}

// mod
[inline]
pub fn (vec Vector3) mod() f32 {
	return f32(math.sqrt(vec.x * vec.x + vec.y * vec.y + vec.z * vec.z))
}

// normalize
pub fn (vec Vector3) normalize() Vector3 {
	m := vec.mod()
	if m == 0 {
		return Vector3{}
	}
	mm := 1 / m
	return Vector3{
		x: vec.x * mm
		y: vec.y * mm
		z: vec.z * mm
	}
}

// cross product
pub fn (a Vector3) cross(b Vector3) Vector3 {
	return Vector3{
		x: (a.y * b.z) - (a.z * b.y)
		y: (a.z * b.x) - (a.x * b.z)
		z: (a.x * b.y) - (a.y * b.x)
	}
}

// vec2
pub fn (vec Vector3) vec2() Vector2 {
	return Vector2{
		x: vec.x
		y: vec.y
	}
}

// Vector2
pub struct Vector2 {
__global:
	x f32
	y f32
}

// vec3
pub fn (vec Vector2) vec3() Vector3 {
	return Vector3{
		x: vec.x
		y: vec.y
	}
}