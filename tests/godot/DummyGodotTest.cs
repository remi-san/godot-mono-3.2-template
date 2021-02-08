using System;
using Godot;
using GodotXUnitApi;
using Xunit;

namespace template.test.godot
{
    public class DummyGodotTest
    {
        [GodotFact]
        public void MyDummyGodotTestTrue()
        {
            Assert.True(true);
        }
    }
}
