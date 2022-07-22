package;

import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;
import openfl.display.ShaderInput;
import openfl.utils.Assets;
import flixel.FlxG;
import openfl.Lib;

class SecondStaticShader extends FlxShader // https://www.shadertoy.com/view/ldjGzV and https://www.shadertoy.com/view/Ms23DR and https://www.shadertoy.com/view/MsXGD4 and https://www.shadertoy.com/view/Xtccz4
{
  @:glFragmentSource('
  uniform vec2 iResolution;
  uniform float iTime;
  float vertJerkOpt = 0.0;
  float vertMovementOpt = 0.0;
  float bottomStaticOpt = 1.0;
  float scalinesOpt = 1.0;
  float rgbOffsetOpt = 1.0;
  float horzFuzzOpt = 1.0;

float rand(vec2 p)
{
    float t = floor(iTime * 20.) / 10.;
    return fract(sin(dot(p, vec2(t * 12.9898, t * 78.233))) * 43758.5453);
}

float noise(vec2 uv, float blockiness)
{   
    vec2 lv = fract(uv);
    vec2 id = floor(uv);
    
    float n1 = rand(id);
    float n2 = rand(id+vec2(1,0));
    float n3 = rand(id+vec2(0,1));
    float n4 = rand(id+vec2(1,1));
    
    vec2 u = smoothstep(0.0, 1.0 + blockiness, lv);

    return mix(mix(n1, n2, u.x), mix(n3, n4, u.x), u.y);
}

float fbm(vec2 uv, int count, float blockiness, float complexity)
{
    float val = 0.0;
    float amp = 0.5;
    
    while(count != 0)
    {
    	val += amp * noise(uv, blockiness);
        amp *= 0.5;
        uv *= complexity;    
        count--;
    }
    
    return val;
}

const float glitchAmplitude = 0.2; // increase this
const float glitchNarrowness = 4.0;
const float glitchBlockiness = 2.0;
const float glitchMinimizer = 8.0; // decrease this

vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec2 mod289(vec2 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float rand(float seed){
    return fract(sin(dot(vec2(seed) ,vec2(12.9898,78.233))) * 43758.5453);
}

vec3 permute(vec3 x) {
  return mod289(((x*34.0)+1.0)*x);
}

float snoise(vec2 v)
  {
  const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                      0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                     -0.577350269189626,  // -1.0 + 2.0 * C.x
                      0.024390243902439); // 1.0 / 41.0
// First corner
  vec2 i  = floor(v + dot(v, C.yy) );
  vec2 x0 = v -   i + dot(i, C.xx);

// Other corners
  vec2 i1;
  //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
  //i1.y = 1.0 - i1.x;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  // x0 = x0 - 0.0 + 0.0 * C.xx ;
  // x1 = x0 - i1 + 1.0 * C.xx ;
  // x2 = x0 - 1.0 + 2.0 * C.xx ;
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;

// Permutations
  i = mod289(i); // Avoid truncation effects in permutation
  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
		+ i.x + vec3(0.0, i1.x, 1.0 ));

  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;

// Gradients: 41 points uniformly over a line, mapped onto a diamond.
// The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;

// Normalise gradients implicitly by scaling m
// Approximation of: m *= inversesqrt( a0*a0 + h*h );
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

// Compute final noise value at P
  vec3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}

float staticV(vec2 uv) {
    float staticHeight = snoise(vec2(9.0,iTime*1.2+3.0))*0.3+5.0;
    float staticAmount = snoise(vec2(1.0,iTime*1.2-6.0))*0.1+0.3;
    float staticStrength = snoise(vec2(-9.75,iTime*0.6-3.0))*2.0+2.0;
	return (1.0-step(snoise(vec2(5.0*pow(iTime,2.0)+pow(uv.x*7.0,1.2),pow((mod(iTime,100.0)+100.0)*uv.y*0.3+3.0,staticHeight))),staticAmount))*staticStrength;
}

vec2 displace(vec2 co, float seed, float seed2) {
    vec2 shift = vec2(0);
    if (rand(seed) > 0.5) {
        shift += 0.1 * vec2(2. * (0.5 - rand(seed2)));
    }
    if (rand(seed2) > 0.6) {
        if (co.y > 0.5) {
            shift.x *= rand(seed2 * seed);
        }
    }
    return shift;
}

vec4 interlace(vec2 co, vec4 col) {
    if (int(co.y) % 3 == 0) {
        return col * ((sin(iTime * 4.) * 0.1) + 0.75) + (rand(iTime) * 0.05);
    }
    return col;
}

void main()
{
  vec2 uv =  openfl_TextureCoordv.xy;

    // Normalized pixel coordinates (from 0 to 1)
	vec2 uv =  fragCoord.xy/iResolution.xy;
    float aspect = iResolution.x / iResolution.y;
    vec2 a = vec2(uv.x * aspect , uv.y);
    vec2 uv2 = vec2(a.x / iResolution.x, exp(a.y));

    
    float shift = glitchAmplitude * pow(fbm(uv2, 4, glitchBlockiness, glitchNarrowness), glitchMinimizer);
    
    float colR = texture2D(bitmap, vec2(uv.x + shift, uv.y)).r * (1. - shift);
    float colG = texture2D(bitmap, vec2(uv.x - shift, uv.y)).g * (1. - shift);
    float colB = texture2D(bitmap, vec2(uv.x - shift, uv.y)).b * (1. - shift);
    
    // Mix with the scanline effect
    vec3 f = vec3(colR, colG, colB);

    
    gl_FragColor = vec4(f, 1.);

    float jerkOffset = (1.0-step(snoise(vec2(iTime*1.3,5.0)),0.8))*0.05;
	
	float fuzzOffset = snoise(vec2(iTime*15.0,uv.y*80.0))*0.003;
	float largeFuzzOffset = snoise(vec2(iTime*1.0,uv.y*25.0))*0.004;
    
    float vertMovementOn = (1.0-step(snoise(vec2(iTime*0.2,8.0)),0.4))*vertMovementOpt;
    float vertJerk = (1.0-step(snoise(vec2(iTime*1.5,5.0)),0.6))*vertJerkOpt;
    float vertJerk2 = (1.0-step(snoise(vec2(iTime*5.5,5.0)),0.2))*vertJerkOpt;
    float yOffset = abs(sin(iTime)*4.0)*vertMovementOn+vertJerk*vertJerk2*0.3;
    float y = mod(uv.y+yOffset,1.0);
    
	
	float xOffset = (fuzzOffset + largeFuzzOffset) * horzFuzzOpt;
    
    float staticVal = 0.0;
   
    for (float y = -1.0; y <= 1.0; y += 1.0) {
        float maxDist = 5.0/200.0;
        float dist = y/200.0;
    	staticVal += staticV(vec2(uv.x,uv.y+dist))*(maxDist-abs(dist))*1.5;
    }
        
    staticVal *= bottomStaticOpt;
	
	float red 	=   texture2D(	bitmap, 	vec2(uv.x + xOffset -0.01*rgbOffsetOpt,y)).r+staticVal;
	float green = 	texture2D(	bitmap, 	vec2(uv.x + xOffset,	  y)).g+staticVal;
	float blue 	=	texture2D(	bitmap, 	vec2(uv.x + xOffset +0.01*rgbOffsetOpt,y)).b+staticVal;
	
	vec3 color = vec3(red,green,blue);
	float scanline = sin(uv.y*800.0)*0.04*scalinesOpt;
	color -= scanline;
	
	gl_FragColor = vec4(color,1.0);
    
    vec2 rDisplace = vec2(0);
    vec2 gDisplace = vec2(0);
    vec2 bDisplace = vec2(0);
    
    if (rand(iTime) > 0.95) {
        rDisplace = displace(uv, iTime * 2., 2. + iTime);
        gDisplace = displace(uv, iTime * 3., 3. + iTime);
        bDisplace = displace(uv, iTime * 5., 5. + iTime);
    }
    
    rDisplace.x += 0.005 * (0.5 - rand(iTime * 37. * uv.y));
    gDisplace.x += 0.007 * (0.5 - rand(iTime * 41. * uv.y));
    bDisplace.x += 0.0011 * (0.5 - rand(iTime * 53. * uv.y));

    rDisplace.y += 0.001 * (0.5 - rand(iTime * 37. * uv.x));
    gDisplace.y += 0.001 * (0.5 - rand(iTime * 41. * uv.x));
    bDisplace.y += 0.001 * (0.5 - rand(iTime * 53. * uv.x));
    
    // Output to screen
    float rcolor = texture2D(bitmap, uv.xy + rDisplace).r;
    float gcolor = texture2D(bitmap, uv.xy + gDisplace).g;
    float bcolor = texture2D(bitmap, uv.xy + bDisplace).b;

    gl_FragColor = mix(vec4(color,1.0), baseColor, alpha) * baseColor.a;    
}


')
public function new()
  {
    super();
  }
}