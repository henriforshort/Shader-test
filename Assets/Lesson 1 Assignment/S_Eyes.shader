Shader "Dorian/Eyes"
{
	Properties
	{
		_Size ("Size",float) = 0
		_Length ("Length", float) = 1
		_EyeSize("EyeSize", float) = 1
		_PupilSize("PupilSize", float) = 1
		_EyeX ("EyeX",Range(-1,1)) = 0
		_EyeY ("EyeY",Range(-1,1)) = 0
		_Seed ("Seed", float) = 1
		_EyeJitterSpeed("EyeJitterSpeed",float) = 0
		_EyeJitterDistance("EyeJitterDistance",float) = 0
		_EyeAngle ("EyeAngle",float) = 0
		_EyeOffset ("EyeOffset",vector) = (0,0,0,0)
		_Right ("Right",float) = 1
		_EyeDistance ("EyeDistance", float) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float data : TEXCOORD1;
				float4 rotatedUV : TEXCOORD2;
				float4 eyeUV : TEXCOORD3;
				
			};

			float _Size;
			float _Length;
			float _EyeSize;
			float _PupilSize;
			float _EyeX;
			float _EyeY;
			float _Seed;
			float _EyeJitterSpeed;
			float _EyeJitterDistance;
			float _EyeAngle;
			float4 _EyeOffset;
			float _EyeDistance;

			float2 rotatedUV(float2 uv, float right)
			{
				float sinX = sin ( _EyeAngle *right );
				float cosX = cos ( _EyeAngle *right);
				float sinY = sin ( _EyeAngle *right);
				float2x2 rotationMatrix = float2x2( cosX, -sinX, sinY, cosX);
				return mul ( uv, rotationMatrix );
			}
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.rotatedUV.xy = v.uv*2-1- _EyeOffset.xy;
				o.rotatedUV.zw = v.uv*2-1- _EyeOffset.zw;

				o.eyeUV = o.rotatedUV + float4(_EyeDistance,0,-_EyeDistance,0);

				o.rotatedUV.xy = rotatedUV(o.rotatedUV.xy,1);
				o.rotatedUV.zw = rotatedUV(o.rotatedUV.zw,-1);
				
				float4 oPos = mul(unity_ObjectToWorld,float4(0,0,0,1)) *10;

				float _rand = (frac(_Seed * pow(10,floor(frac(_Time.y *_EyeJitterSpeed )*10)))-.5)*2;
				 o.data = _rand;
				return o;
			}
			
			float4 frag (v2f i) : SV_Target
			{
				float2 doubleUV = lerp(i.rotatedUV.xy,i.rotatedUV.zw, step(i.uv.x,.5));
				float2 eyeUV = lerp(i.eyeUV.xy,i.eyeUV.zw, step(i.uv.x,.5));
				//return float4(i.rotatedUV.xy ,0,1);
				//return float4(doubleUV,0,1);
				//return doubleUV.y;
				
				//float hypno = (sin((1-length((i.uv-.5)*2)+_Time.y*0)*20)+1)/2;
				float2 newUV = i.uv*2 -1;//(i.rotatedUV-.5)*2;
				float4 col = length(doubleUV- (float2(clamp(doubleUV.x,-_Length,_Length),0)));
				//col = col *_Size;

				col = step(_Size, col);

				clip(1-col-.5);
				float color = step(_EyeSize,1-length(eyeUV + float2(_EyeX + i.data *_EyeJitterDistance,_EyeY)));
				color = color - step(_EyeSize + _PupilSize,1-length(eyeUV + float2(_EyeX+ i.data *_EyeJitterDistance,_EyeY)));
				return color;
			}
			ENDCG
		}
	}
}
