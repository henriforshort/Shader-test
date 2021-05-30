Shader "Unlit/testCapsule" {
    Properties {
        _size ("edge size", Range(0.0001,.5)) = .1
    }
    SubShader {
        Tags { "RenderType"="Transparent"
            "Queue"="Transparent" }

        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            
            float _size;

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            float clamp (float min, float max, float t) {
                float tooLow = t < min;
                float tooHigh = max < t;
                return lerp (lerp(t, min, tooLow), max, tooHigh);
            }

            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                float2 closestSegmentPoint = float2(
                    clamp(_size, 1-_size, i.uv.x),
                    clamp(_size, 1-_size, i.uv.y));
                float distance = length(closestSegmentPoint - i.uv);
                //return float4(i.uv, 0, 1);
                //return float4(closestSegmentPoint, 0, 1);
                return distance < _size;
            }
            ENDCG
        }
    }
}
