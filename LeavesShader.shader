Shader "Custom/LeavesShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _NoiseTex ("Noise texture", 2D) = "white" {}
        _NormalTex ("Normal texture", 2D) = "bump" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Cutoff ("Alpha cutoff", Range(0, 1)) = 0.5
        _BendFactor ("Bend factor", Range(0, 5)) = 1
        _Speed ("Bend speed", Range(0, 50)) = 10
        _Direction ("Bend direction", vector) = (1.0, 1.0, 0.0, 0.0)
        _NoiseScale ("Noise scale", Range(0, 2)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard alpha:blend fullforwardshadows vertex:vert

        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _NoiseTex;
        sampler2D _NormalTex;
        float _BendFactor;
        float _Speed;
        float4 _Direction;
        float _NoiseScale;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        void vert(inout appdata_full v) 
        {
            float3 vertPos = v.vertex;

            float remapedPosY = vertPos.y * _BendFactor / 100 * sin(_Time * _Speed);
            float distortedPosY = pow(remapedPosY, 2) - remapedPosY;
            float2 directedPos = distortedPosY * _Direction;
            float3 distortedPos = float3(directedPos.x, 0, directedPos.y) + vertPos;

            float4 newTexCoord = float4(vertPos.xz * _NoiseScale * sin(_Time * _Speed / 10000), 0, 0);
            float noiseX = (0.5 - tex2Dlod(_NoiseTex, newTexCoord).r) * _BendFactor / 5;
            float noiseY = (0.5 - tex2Dlod(_NoiseTex, newTexCoord + 50).r) * _BendFactor / 5;
            float noiseZ = (0.5 - tex2Dlod(_NoiseTex, newTexCoord + 100).r) * _BendFactor / 5;
            float3 noise = float3(noiseX, noiseY, noiseZ);

            float3 finalPosition = lerp(vertPos, distortedPos + noise, v.texcoord.x + v.texcoord.y);
            v.vertex = float4(finalPosition, 0);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            //fixed4 c = float4(IN.uv_MainTex, 0, 1);
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
            o.Normal = UnpackNormal(tex2D(_NormalTex, IN.uv_MainTex));
        }
        ENDCG
    }
    FallBack "Transparent/Cutout/VertexLit"
}
