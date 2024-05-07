
#include <stddef.h>
#include "bindings.h"


// Core
void _ClearBackground(Color *color)
{
    ClearBackground(*color);
}

void _BeginMode3D(Camera3D *camera)
{
    BeginMode3D(*camera);
}

void _BeginMode2D(Camera2D *camera)
{
    BeginMode2D(*camera);
}


// Module: rshape
// Draw a color-filled circle
void _DrawCircle(int centerX, int centerY, float radius, Color *color)
{
    DrawCircleV((Vector2){ (float)centerX, (float)centerY }, radius, *color);
}

void _DrawCircleV(Vector2 *center, float radius, Color *color)
{
    DrawCircleSector(*center, radius, 0, 360, 36, *color);
}


void _DrawLine(int startPosX, int startPosY, int endPosX, int endPosY, Color *color)
{
    DrawLine(startPosX, startPosY, endPosX, endPosY, *color);
}

void _DrawLineV(Vector2 *startPos, Vector2 *endPos, Color *color)
{
    DrawLineV(*startPos, *endPos, *color);
}

void _DrawCircleLines(int centerX, int centerY, float radius, Color *color)
{
    DrawCircleLines(centerX, centerY, radius, *color);
}

void _DrawRectangleV(Vector2 *position, Vector2 *size, Color *color)
{
    DrawRectangleV(*position, *size, *color);
}

void _DrawRectanglePro(Rectangle *rec, Vector2 *origin, float rotation, Color *color)
{
    DrawRectanglePro(*rec, *origin, rotation, *color);
}

void _DrawPoly(Vector2 *center, int sides, float radius, float rotation, Color *color)
{
    DrawPoly(*center, sides, radius, rotation, *color);
}

void _DrawPolyLines(Vector2 *center, int sides, float radius, float rotation, Color *color)
{
    DrawPolyLines(*center, sides, radius, rotation, *color);
}

void _DrawPolyLinesEx(Vector2 *center, int sides, float radius, float rotation, float lineThick, Color *color)
{
    DrawPolyLinesEx(*center, sides, radius, rotation, lineThick, *color);
}


// Module: rmodel

void _DrawCube(Vector3 *position, float width, float height, float length, Color *color)
{
    DrawCube(*position, width, height, length, *color);
}

void _DrawCubeV(Vector3 *position, Vector3 size, Color *color)
{
    DrawCubeV(*position, size, *color);
}

void _DrawCubeWires(Vector3 *position, float width, float height, float length, Color *color)
{
    DrawCubeWires(*position, width, height, length, *color);
}

void _DrawCubeWiresV(Vector3 *position, Vector3 *size, Color *color)
{
    DrawCubeWiresV(*position, *size, *color);
}

// Module: text

void _DrawText(const char *text, int posX, int posY, int fontSize, Color *color)
{
    DrawText(text, posX, posY, fontSize, *color);
}
