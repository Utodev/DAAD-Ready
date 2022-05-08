/*
    OpenGL fragment shader for CRT visual artifacts emulation
    Copyright (C) 2010-2012,2016 cgwg, Themaister, DOLLS, A Grosz

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
*/
uniform float interlacedLineShade;
uniform vec2 resolution;
uniform float palMode;
uniform vec2 sourceTextureSize;
uniform sampler2D textureID;
uniform sampler2D paletteID;
#define PI 3.141592653589  
#define FIXDIVZERO(c) max(abs(c), 1e-5)
#define ASPECT vec2(1.0, 0.75)
#define x_tilt 0.0
#define y_tilt 0.0
// curvature radius
#define R 2.0
#define d 1.5   // (1.5, 0.1, 3.0, 0.1)
#define sinangle sin(vec2(max(abs(x_tilt), 1e-3), max(abs(y_tilt), 1e-3)))
#define cosangle cos(vec2(max(abs(x_tilt), 1e-3), max(abs(y_tilt), 1e-3)))

float intersect(vec2 xy)
{  
	  float A = dot(xy,xy) + d*d;  
	  float B = 2.0*(R*(dot(xy,sinangle) - d*cosangle.x*cosangle.y) - d*d);  
	  float C = d*d + 2.0*R*d*cosangle.x*cosangle.y;  
	  return (-B - sqrt(B*B - 4.0*A*C)) / (2.0*A);  
}  

vec2 bkwtrans(vec2 xy)  
{  
	  float c = intersect(xy);  
	  vec2 point = vec2(c)*xy;  
	  point -= vec2(-R)*sinangle;  
	  point /= vec2(R);  
	  vec2 tang = sinangle / cosangle;  
	  vec2 poc = point / cosangle;  
	  float A = dot(tang,tang) + 1.0;  
	  float B = -2.0*dot(poc,tang);  
	  float C = dot(poc,poc) - 1.0;  
	  float a = (-B + sqrt(B*B - 4.0*A*C)) / (2.0*A);  
	  vec2 uv = (point - a*sinangle) / cosangle;  
	  float r = R*acos(a);  
	  return uv*r / sin(r / R);  
}  
vec2 fwtrans(vec2 uv)  
{  
	  float r = FIXDIVZERO(sqrt(dot(uv,uv)));  
	  uv *= sin(r / R) / r;  
	  float x = 1.0 - cos(r / R);  
	  float D = d / R + x*cosangle.x*cosangle.y + dot(uv,sinangle);  
	  return d*(uv*cosangle - x*sinangle) / D;  
}  
vec3 maxscale()  
{  
	  vec2 c = bkwtrans(-R * sinangle / (1.0 + R / d*cosangle.x*cosangle.y));  
	  vec2 a = vec2(0.5,0.5)*ASPECT;  
	  vec2 lo = vec2(fwtrans(vec2(-a.x,c.y)).x, fwtrans(vec2(c.x,-a.y)).y) / ASPECT;  
	  vec2 hi = vec2(fwtrans(vec2(+a.x,c.y)).x, fwtrans(vec2(c.x,+a.y)).y) / ASPECT;  
	  return vec3((hi + lo)*ASPECT*0.5,max(hi.x - lo.x,hi.y - lo.y));  
}  
	    
#define cornersize 0.03  
#define cornersmooth 1000.0  
#define overscan_x 100.0
#define overscan_y 100.0
#define CRTGAMMA 2.4
#define TARGETGAMMA 2.2
#define x_tilt 0.0
#define y_tilt 0.0
#define UPSAMPLING
#define TEX2D(c) pow(texture2D(textureID, (c)), vec4(CRTGAMMA))
#define SHARPER 1.5
#define DOTMASK 0.5

vec2 transform(vec2 coord)
{
	//  coord *= TextureSize / InputSize;
	vec3 stretch = maxscale();
	coord = (coord - vec2(0.5))*ASPECT*stretch.z + stretch.xy;
	return (bkwtrans(coord) / ASPECT + vec2(0.5));
}

float corner(vec2 coord)  
{  
	coord = min(coord, vec2(1.0) - coord) * ASPECT;
	vec2 cdist = vec2(cornersize);
	coord = (cdist - min(coord,cdist));
	float dist = sqrt(dot(coord,coord));
	return clamp((cdist.x - dist)*cornersmooth,0.0, 1.0);
}  

vec4 scanlineWeights(float distance, vec4 color)
{  
	vec4 wid = 0.3 + 0.1 * pow(color, vec4(3.0));
	vec4 weights = vec4(distance / wid);
	return 0.5 * exp(-weights * weights) / (wid);
}

//
// PAL conversion, TODO: make it input YUV
//
vec4 rgb2yuv(vec4 rgb)
{
	const mat4 yuvcoeffs = mat4(
		0.299,	-0.147,  0.615, 0.000,
		0.587,	-0.289, -0.515, 0.000,
		0.114,	 0.436, -0.100, 0.000,
		0.000,	 0.000,  0.000, 0.000
	);
	return yuvcoeffs * rgb;
}

vec4 yuv2rgb(vec4 yuv)
{
	const mat4 rgbcoeffs = mat4(
		1.000,	1.000,	1.000,	0.000,
		0.000,	-0.395,	2.032,	0.000,
		1.140,	-0.581,	0.000,	0.000,
		0.000,	0.000,	0.000,	0.000
	);
	return rgbcoeffs * yuv;
}

vec4 filteredPixel(vec2 tex, vec2 one)
{
	vec4 yuv;
	vec4 yuvr0 = rgb2yuv(TEX2D(tex + vec2(-one.x * 5.0, -one.y)));
	vec4 yuvr1 = rgb2yuv(TEX2D(tex + vec2(-one.x * 5.0, 0.0)));
	vec4 yuvp0 = rgb2yuv(TEX2D(tex + vec2(-one.x * 4.0, -one.y)));
	vec4 yuvp1 = rgb2yuv(TEX2D(tex + vec2(-one.x * 4.0, 0.0)));
	vec4 yuvm0 = rgb2yuv(TEX2D(tex + vec2(-one.x * 3.0, -one.y)));
	vec4 yuvm1 = rgb2yuv(TEX2D(tex + vec2(-one.x * 3.0, 0.0)));
	vec4 yuv00 = rgb2yuv(TEX2D(tex + vec2(-one.x * 2.0, -one.y)));
	vec4 yuv01 = rgb2yuv(TEX2D(tex + vec2(-one.x * 2.0, 0.0)));
	vec4 yuv10 = rgb2yuv(TEX2D(tex + vec2(-one.x, -one.y)));
	vec4 yuv11 = rgb2yuv(TEX2D(tex + vec2(-one.x, 0.0)));
	vec4 yuv20 = rgb2yuv(TEX2D(tex + vec2(0.0, -one.y)));
	vec4 yuv21 = rgb2yuv(TEX2D(tex));
	vec4 yuv30 = rgb2yuv(TEX2D(tex + vec2(one.x, -one.y)));
	vec4 yuv31 = rgb2yuv(TEX2D(tex + vec2(one.x, 0.0)));
	vec4 yuv40 = rgb2yuv(TEX2D(tex + vec2(2.0 * one.x, -one.y)));
	vec4 yuv41 = rgb2yuv(TEX2D(tex + vec2(2.0 * one.x, 0.0)));
	
	// R contains the luma component
	yuv.r = (yuv01.r + yuv41.r) * 0.07 + (yuv11.r + yuv31.r) * 0.17 + yuv21.r * 0.52;
	// TODO: fix chroma filter coefficients
	yuv.gb = ((yuvr0.gb + yuv00.gb + yuv30.gb + yuv40.gb + yuv10.gb + yuvm0.gb + yuv20.gb + yuvp0.gb) * palMode
		    + yuv11.gb + yuv31.gb + yuvr1.gb + yuv01.gb + yuv41.gb + yuv21.gb + yuvp1.gb + yuvm1.gb) / 8.0 / (palMode + 1.0)
		  ;
	
	vec4 tmp = yuv2rgb(yuv);

	return tmp;
}

void main()  
{  
	vec2 TextureSize = sourceTextureSize.xy;
#if 1
	vec2 xy = transform(gl_TexCoord[0].xy);
#else
	vec2 xy = gl_TexCoord[0].xy;
#endif
	vec2 ilfac = vec2(1.0, floor(sourceTextureSize.y / 200.0));
	vec2 sharpTextureSize = vec2(SHARPER * TextureSize.x, TextureSize.y);
	vec2 one = ilfac / sharpTextureSize;
	float cval = corner(xy);
	vec2 ilvec = vec2(0.0, ilfac.y > 1.5 ? mod(float( 50.0 ), 2.0) : 0.0);
	vec2 ratio_scale = (xy * TextureSize - vec2(0.5) + ilvec)/ilfac;
	vec2 uv_ratio = fract(ratio_scale);
	xy = (floor(ratio_scale) * ilfac + vec2(0.5) - ilvec) / TextureSize;
#if defined(UPSAMPLING)
	// Lanczos upsampling
	vec4 coeffs = PI * vec4(1.0 + uv_ratio.x, uv_ratio.x, 1.0 - uv_ratio.x, 2.0 - uv_ratio.x);
	coeffs = FIXDIVZERO(coeffs);
	coeffs = 2.0 * sin(coeffs) * sin(coeffs / 2.0) / (coeffs * coeffs);
	coeffs /= dot(coeffs, vec4(1.0));
	float scaley = TextureSize.y / 288.0;
	vec2 unit = vec2(1.0, scaley) / TextureSize;
	vec4 p1 = filteredPixel((xy + vec2(-one.x, 0.0)), unit);
	vec4 p2 = filteredPixel((xy), unit);
	vec4 p3 = filteredPixel((xy + vec2(one.x, 0.0)), unit);
	vec4 p4 = filteredPixel((xy + vec2(2.0 * one.x, 0.0)), unit);
	vec4 col  = clamp(mat4( p1, p2, p3, p4) * coeffs, 0.0, 1.0);
	p1 = filteredPixel((xy + vec2(-one.x, one.y)), unit);
	p2 = filteredPixel((xy + vec2(0.0, one.y)), unit);
	p3 = filteredPixel((xy + one), unit);
	p4 = filteredPixel((xy + vec2(2.0 * one.x, one.y)), unit);
	vec4 col2 = clamp(mat4( p1, p2, p3, p4) * coeffs, 0.0, 1.0);
#else
	vec4 col = filteredPixel(xy, one);
	vec4 col2 = filteredPixel(xy + vec2(0, one.y), one);
#endif
	//
	vec4 weights  = scanlineWeights(uv_ratio.y, col);
	vec4 weights2 = scanlineWeights((1.0 - uv_ratio.y), col2);
	vec3 outputpixel = (col * weights + col2 * weights2).rgb * vec3(cval);
	float modfactor = floor(mod(gl_FragCoord.x - mod(gl_FragCoord.y, 2.0), 2.0));
	vec3 dotMaskWeights = mix(
		vec3(1.0, 1.0 - DOTMASK, 1.0),
		vec3(1.0 - DOTMASK, 1.0, 1.0 - DOTMASK),
		modfactor
    );
	outputpixel *= dotMaskWeights;  
	outputpixel = pow(outputpixel, vec3(1.0 / TARGETGAMMA));
	gl_FragColor = vec4(outputpixel, 0.0);  
}
